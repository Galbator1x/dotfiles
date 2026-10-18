#!/bin/bash
set -eu

action=${1:-restore}
case "$action" in save|restore|forget|build|check|diagnose) ;; *) echo 'Usage: window-position.sh save|restore|forget|build|check|diagnose' >&2; exit 2 ;; esac
aerospace_bin=$(command -v aerospace || true)
[[ -n "$aerospace_bin" ]] || aerospace_bin=/opt/homebrew/bin/aerospace
state_root="$HOME/Library/Application Support/dotfiles"
state_dir="$state_root/window-positions"
script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
helper_dir="$HOME/Library/Caches/dotfiles"
helper_bin="$helper_dir/window-position-helper"
if [[ "$action" == check || "$action" == diagnose ]]; then
    umask 077
    report="$HOME/Library/Logs/dotfiles/window-position-check.log"
    mkdir -p "$(dirname "$report")"
    set +e
    (
        set -e
        printf 'Window position: %s\nCaller: %s\n' "$action" "${WINDOW_POSITION_DIAGNOSTIC_CALLER:-terminal/other}"
        date '+%Y-%m-%d %H:%M:%S %z'
        [[ -x "$helper_bin" ]] || { echo 'Build the helper first: window-position.sh build'; exit 1; }
        "$aerospace_bin" --version
        workspace=$("$aerospace_bin" list-workspaces --focused)
        printf 'Focused workspace: %s\n' "$workspace"
        window=$("$aerospace_bin" list-windows --focused --format '%{window-id}|%{app-bundle-id}|%{workspace}|%{window-layout}|%{window-is-fullscreen}')
        printf 'Focused window (ID|app|workspace|layout|fullscreen): %s\n' "${window:-none}"
        IFS='|' read -r window_id bundle window_workspace layout fullscreen <<< "$window"
        "$helper_bin" check-cli "$aerospace_bin" "${bundle:-com.example.window-position-check}"
        if [[ "$action" == diagnose ]]; then
            "$helper_bin" check-access
            if [[ "$window_id" =~ ^[0-9]+$ && "$bundle" =~ ^[a-zA-Z0-9._-]+$ ]]; then
                saved_file="$state_dir/$bundle.txt"
                if [[ -f "$saved_file" ]]; then
                    printf 'Saved position (workspace, then x y width height):\n'
                    cat "$saved_file"
                    stat -f 'Saved at: %Sm' "$saved_file"
                    IFS= read -r saved_workspace < "$saved_file"
                    [[ "$saved_workspace" == "$workspace" ]] || printf 'Restore skipped: saved workspace is %s\n' "$saved_workspace"
                else
                    echo 'Restore skipped: no saved position'
                fi
                echo 'Current geometry (x y width height), or skip reason:'
                "$helper_bin" inspect "$aerospace_bin" "$bundle" "$workspace" "$window_id"
            else
                echo 'Geometry skipped: no focused window'
            fi
        fi
    ) > "$report" 2>&1
    status=$?
    set -e
    printf 'Exit status: %s\n' "$status" >> "$report"
    cat "$report"
    printf 'Report: %s\n' "$report"
    [[ "${2:-}" != --open ]] || /usr/bin/open -t "$report"
    exit "$status"
fi
build_helper() {
    if [[ ! -x "$helper_bin" || "$script_dir/window-position.swift" -nt "$helper_bin" ]]; then
        mkdir -p "$helper_dir"
        local build_directory temporary_binary
        build_directory=$(mktemp -d "$helper_dir/.window-position.XXXXXX")
        temporary_binary="$build_directory/window-position-helper"
        if ! /usr/bin/swiftc -O "$script_dir/window-position.swift" -o "$temporary_binary"; then
            rm -rf -- "$build_directory"
            return 1
        fi
        mv -- "$temporary_binary" "$helper_bin"
        rmdir -- "$build_directory"
    fi
}
if [[ "$action" == build ]]; then
    build_helper
    exit
fi

if [[ ! -x "$helper_bin" ]]; then
    echo 'Build the helper first: bash ~/projects/dotfiles/scripts/window-position.sh build' >&2
    exit 1
fi

umask 077
mkdir -p "$state_root"
generation_file="$state_root/window-position-generation"
expected_workspace=""
[[ "$action" != restore ]] || expected_workspace=${AEROSPACE_FOCUSED_WORKSPACE:-}
callback_state=$("$helper_bin" begin "$aerospace_bin" "$expected_workspace" "$generation_file")
[[ -n "$callback_state" ]] || exit 0
{ IFS= read -r workspace; IFS= read -r generation; } <<< "$callback_state"

if [[ "$action" != restore ]]; then
    bundle=$("$aerospace_bin" list-windows --focused --format '%{app-bundle-id}')
    [[ "$bundle" =~ ^[a-zA-Z0-9._-]+$ ]] || exit 1
    state_file="$state_dir/$bundle.txt"
    if [[ "$action" == forget ]]; then
        "$helper_bin" commit "$generation_file" "$generation" "$state_file" forget > /dev/null
        exit
    fi
    window_id=$("$aerospace_bin" list-windows --focused --format '%{window-id}')
    [[ "$window_id" =~ ^[0-9]+$ ]] || exit 1
    bounds=$("$helper_bin" save "$aerospace_bin" "$bundle" "$workspace" "$window_id")
    [[ -n "$bounds" ]] || { echo 'Expected exactly one visible floating standard application window.' >&2; exit 1; }
    [[ "$("$aerospace_bin" list-workspaces --focused)" == "$workspace" ]] || exit 1
    umask 077
    mkdir -p "$state_dir"
    result=$("$helper_bin" commit "$generation_file" "$generation" "$state_file" save "$workspace"$'\n'"$bounds"$'\n')
    [[ "$result" != committed ]] || echo "Saved $bundle on workspace $workspace: $bounds"
    exit
fi

[[ -d "$state_dir" ]] || exit 0
shopt -s nullglob
for state_file in "$state_dir"/*.txt; do
    IFS= read -r current_generation < "$generation_file" || exit 0
    [[ "$current_generation" == "$generation" ]] || exit 0
    if ! {
        IFS= read -r saved_workspace &&
        read -r x y width height
    } < "$state_file"; then
        continue
    fi
    [[ "$saved_workspace" == "$workspace" ]] || continue
    valid=true
    for value in "$x" "$y" "$width" "$height"; do
        [[ "$value" =~ ^-?[0-9]+$ ]] || valid=false
    done
    [[ "$valid" == true ]] || continue
    bundle=${state_file##*/}
    bundle=${bundle%.txt}
    [[ "$bundle" =~ ^[a-zA-Z0-9._-]+$ && "$width" -gt 0 && "$height" -gt 0 ]] || continue
    # The helper owns window selection and all live window/workspace checks.
    "$helper_bin" restore "$aerospace_bin" "$bundle" "$workspace" auto "$x" "$y" "$width" "$height" "$generation_file" "$generation" || continue
done
