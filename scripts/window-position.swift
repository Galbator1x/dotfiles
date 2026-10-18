import AppKit
import ApplicationServices
import Foundation
import Darwin
import Dispatch

// AeroSpace uses this same API to map Accessibility objects to CGWindowIDs.
@_silgen_name("_AXUIElementGetWindow")
func AXWindowID(_ element: AXUIElement, _ id: UnsafeMutablePointer<CGWindowID>) -> AXError

struct Failure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

func query(_ aerospace: String, _ arguments: [String]) throws -> String {
    let process = Process()
    let completed = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in completed.signal() }
    let output = Pipe()
    process.executableURL = URL(fileURLWithPath: aerospace)
    process.arguments = arguments
    process.standardOutput = output
    try process.run()
    let data = output.fileHandleForReading.readDataToEndOfFile()
    completed.wait()
    guard process.terminationStatus == 0 else { throw Failure("AeroSpace query failed") }
    return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
}

func managedWindows(_ aerospace: String, bundle: String) throws -> String {
    try query(aerospace, [
        "list-windows", "--monitor", "all", "--app-bundle-id", bundle,
        "--format", "%{window-id}|%{workspace}|%{window-layout}|%{window-is-fullscreen}",
    ])
}

func withStateLock(_ generationFile: String, _ body: () throws -> Void) throws {
    let descriptor = open(generationFile + ".lock", O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
    guard descriptor >= 0 else { throw Failure("Cannot open callback lock") }
    defer { close(descriptor) }
    guard flock(descriptor, LOCK_EX) == 0 else { throw Failure("Cannot lock callback state") }
    defer { flock(descriptor, LOCK_UN) }
    try body()
}

func beginRestore(aerospace: String, expectedWorkspace: String, generationFile: String) throws {
    // Keep the workspace query and token publication in the same critical section.
    try withStateLock(generationFile) {
        let workspace = try query(aerospace, ["list-workspaces", "--focused"])
        guard !workspace.isEmpty, expectedWorkspace.isEmpty || expectedWorkspace == workspace else { return }
        let generation = UUID().uuidString
        try (generation + "\n").write(toFile: generationFile, atomically: true, encoding: .utf8)
        print(workspace)
        print(generation)
    }
}

func commitPosition(generationFile: String, generation: String, path: String, contents: String?) throws {
    try withStateLock(generationFile) {
        let current = try String(contentsOfFile: generationFile, encoding: .utf8)
        guard current.trimmingCharacters(in: .whitespacesAndNewlines) == generation else {
            print("superseded")
            return
        }
        if let contents {
            try contents.write(toFile: path, atomically: true, encoding: .utf8)
        } else if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
        print("committed")
    }
}

struct Target {
    let aerospace: String
    let bundle: String
    let workspace: String
    var id: CGWindowID
    let generationFile: String?
    let generation: String?
    var diagnostics = false

    func report(_ reason: String) {
        if diagnostics { FileHandle.standardError.write(Data("Skipped: \(reason)\n".utf8)) }
    }

    func floatingWindowID() throws -> CGWindowID? {
        let windows = try managedWindows(aerospace, bundle: bundle)
        guard !windows.isEmpty else { report("no managed windows for \(bundle)"); return nil }
        guard !windows.contains("\n") else { report("multiple managed windows for \(bundle)"); return nil }
        let fields = windows.components(separatedBy: "|")
        guard fields.count == 4 else { report("unexpected AeroSpace window format"); return nil }
        guard fields[1] == workspace else { report("window belongs to workspace \(fields[1]), expected \(workspace)"); return nil }
        guard fields[2] == "floating" else { report("layout is \(fields[2]), expected floating"); return nil }
        guard fields[3] == "false" else { report("AeroSpace fullscreen window"); return nil }
        return CGWindowID(fields[0])
    }

    func currentWindowID() throws -> CGWindowID? {
        if let file = generationFile, let expected = generation {
            guard (try? String(contentsOfFile: file, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)) == expected else { return nil }
        }
        let focused = try query(aerospace, ["list-workspaces", "--focused"])
        guard focused == workspace else { report("focused workspace changed to \(focused)"); return nil }
        guard let currentID = try floatingWindowID() else { return nil }
        // Recheck after the query, which may have crossed a workspace transition.
        if let file = generationFile, let expected = generation {
            guard (try? String(contentsOfFile: file, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)) == expected else { return nil }
        }
        guard try query(aerospace, ["list-workspaces", "--focused"]) == workspace else {
            report("workspace changed during validation"); return nil
        }
        return currentID
    }

    func isCurrent() throws -> Bool { try currentWindowID() == id }
}

func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
    return value
}

func window(for target: Target) -> AXUIElement? {
    let applications = NSRunningApplication.runningApplications(withBundleIdentifier: target.bundle)
    guard applications.count == 1, let app = applications.first else {
        target.report("expected one running application process"); return nil
    }
    guard !app.isHidden else { target.report("application is hidden"); return nil }
    let application = AXUIElementCreateApplication(app.processIdentifier)
    AXUIElementSetMessagingTimeout(application, 0.3)
    guard let windows = attribute(application, kAXWindowsAttribute) as? [AXUIElement] else {
        target.report("Accessibility could not read the application's windows"); return nil
    }
    let matches = windows.filter {
        var id: CGWindowID = 0
        return AXWindowID($0, &id) == .success && id == target.id
    }
    guard matches.count == 1, let window = matches.first else {
        target.report("Accessibility window ID does not match \(target.id)"); return nil
    }
    guard attribute(window, kAXSubroleAttribute) as? String == kAXStandardWindowSubrole else {
        target.report("window is not AXStandardWindow"); return nil
    }
    guard attribute(window, kAXMinimizedAttribute) as? Bool == false else {
        target.report("window is minimized or AXMinimized is unavailable"); return nil
    }
    guard attribute(window, "AXFullScreen") as? Bool != true else {
        target.report("native fullscreen window"); return nil
    }
    return window
}

func geometry(_ window: AXUIElement) -> (CGPoint, CGSize)? {
    guard let position = attribute(window, kAXPositionAttribute),
          let size = attribute(window, kAXSizeAttribute),
          CFGetTypeID(position) == AXValueGetTypeID(), CFGetTypeID(size) == AXValueGetTypeID() else { return nil }
    var point = CGPoint.zero
    var dimensions = CGSize.zero
    guard AXValueGetValue(position as! AXValue, .cgPoint, &point),
          AXValueGetValue(size as! AXValue, .cgSize, &dimensions) else { return nil }
    return (point, dimensions)
}

func run() throws {
    let args = Array(CommandLine.arguments.dropFirst())
    if args == ["check-access"] {
        print(AXIsProcessTrusted() ? "Accessibility: allowed" : "Accessibility: required")
        return
    }
    if args.count == 3, args[0] == "check-cli" {
        let windows = try managedWindows(args[1], bundle: args[2])
        print("CLI contract: PASS")
        if !windows.isEmpty { print(windows) }
        return
    }
    if args.count == 4, args[0] == "begin" {
        try beginRestore(aerospace: args[1], expectedWorkspace: args[2], generationFile: args[3])
        return
    }
    if args.first == "commit" {
        guard (args.count == 5 && args[4] == "forget") || (args.count == 6 && args[4] == "save") else {
            throw Failure("Invalid position commit arguments")
        }
        try commitPosition(generationFile: args[1], generation: args[2], path: args[3],
                           contents: args.count == 6 ? args[5] : nil)
        return
    }
    guard args.count == 5 || args.count == 11,
          ["save", "inspect", "restore"].contains(args[0]) else {
        throw Failure("Invalid window-position helper arguments")
    }
    let inspecting = args[0] == "inspect"
    let saving = args[0] != "restore"
    guard saving ? args.count == 5 : args.count == 11 else { throw Failure("Invalid argument count") }
    guard let id = CGWindowID(args[4]) ?? (!saving && args[4] == "auto" ? 0 : nil) else {
        throw Failure("Invalid window ID")
    }
    var target = Target(aerospace: args[1], bundle: args[2], workspace: args[3], id: id,
                        generationFile: saving ? nil : args[9], generation: saving ? nil : args[10])
    target.diagnostics = inspecting
    guard let currentID = try target.currentWindowID() else { return }
    if args[4] == "auto" { target.id = currentID }
    else if currentID != target.id { target.report("window ID changed"); return }
    guard AXIsProcessTrusted() else {
        throw Failure("Grant Accessibility access to the window-position-helper in macOS System Settings")
    }
    guard let window = window(for: target) else { return }
    guard let (position, size) = geometry(window) else { target.report("cannot read window geometry"); return }
    if saving {
        guard try target.isCurrent() else { return }
        print("\(Int(position.x)) \(Int(position.y)) \(Int(size.width)) \(Int(size.height))")
        return
    }
    let numbers = args[5...8].compactMap(Double.init)
    guard numbers.count == 4, numbers.allSatisfy({ $0.isFinite }), numbers[2] > 0, numbers[3] > 0 else {
        throw Failure("Invalid saved geometry")
    }
    var savedPosition = CGPoint(x: numbers[0], y: numbers[1])
    var savedSize = CGSize(width: numbers[2], height: numbers[3])
    if size != savedSize {
        guard try target.isCurrent(), let value = AXValueCreate(.cgSize, &savedSize) else { return }
        guard AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, value) == .success else {
            throw Failure("Cannot resize the saved window")
        }
    }
    // Resizing can itself change an application's window origin.
    guard let (currentPosition, _) = geometry(window) else { return }
    if currentPosition != savedPosition {
        guard try target.isCurrent(), let value = AXValueCreate(.cgPoint, &savedPosition) else { return }
        guard AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, value) == .success else {
            throw Failure("Cannot move the saved window")
        }
    }
}

do { try run() } catch {
    FileHandle.standardError.write(Data("window-position: \(error)\n".utf8))
    exit(1)
}
