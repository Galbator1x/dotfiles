use scripting additions

on run argv
    tell application "System Events"
        set matches to application processes whose bundle identifier is (item 7 of argv)
        if (count matches) is not 1 then return ""
        tell item 1 of matches
            if visible is false then return ""
            set candidates to windows whose subrole is "AXStandardWindow"
            -- Avoid moving a dialog or choosing arbitrarily between multiple main windows.
            if (count candidates) is not 1 then return ""
            set targetWindow to item 1 of candidates
            if value of attribute "AXMinimized" of targetWindow then return ""
            if exists attribute "AXFullScreen" of targetWindow then
                if value of attribute "AXFullScreen" of targetWindow then return ""
            end if
            if item 1 of argv is "save" then
                set {x, y} to position of targetWindow
                set {w, h} to size of targetWindow
                return (x as text) & " " & (y as text) & " " & (w as text) & " " & (h as text)
            end if
            set savedPosition to {(item 2 of argv as integer), (item 3 of argv as integer)}
            set savedSize to {(item 4 of argv as integer), (item 5 of argv as integer)}
            -- System Events can be slow: the workspace may change while resolving the window.
            if (my focusedWorkspace(item 6 of argv)) is not (item 8 of argv) then return ""
            if size of targetWindow is not savedSize then set size of targetWindow to savedSize
            if (my focusedWorkspace(item 6 of argv)) is not (item 8 of argv) then return ""
            if position of targetWindow is not savedPosition then set position of targetWindow to savedPosition
        end tell
    end tell
end run

on focusedWorkspace(aerospacePath)
    return do shell script ((quoted form of aerospacePath) & " list-workspaces --focused")
end focusedWorkspace
