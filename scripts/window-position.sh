#!/bin/bash
set -eu

action=${1:-restore}
case "$action" in save|restore|forget) ;; *) echo 'Usage: window-position.sh save|restore|forget' >&2; exit 2 ;; esac
aerospace_bin=$(command -v aerospace || true)
[[ -n "$aerospace_bin" ]] || aerospace_bin=/opt/homebrew/bin/aerospace
state_root="$HOME/Library/Application Support/dotfiles"
state_dir="$state_root/window-positions"
script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
workspace=$("$aerospace_bin" list-workspaces --focused)
[[ -n "$workspace" ]] || exit 0

if [[ "$action" != restore ]]; then
    bundle=$("$aerospace_bin" list-windows --focused --format '%{app-bundle-id}')
    [[ "$bundle" =~ ^[a-zA-Z0-9._-]+$ ]] || exit 1
    state_file="$state_dir/$bundle.txt"
    if [[ "$action" == forget ]]; then
        rm -f -- "$state_file"
        exit
    fi
    bounds=$(/usr/bin/osascript "$script_dir/window-position.applescript" save 0 0 0 0 "$aerospace_bin" "$bundle" "$workspace")
    [[ -n "$bounds" ]] || { echo 'Expected exactly one visible standard application window.' >&2; exit 1; }
    [[ "$("$aerospace_bin" list-workspaces --focused)" == "$workspace" ]] || exit 1
    umask 077
    mkdir -p "$state_dir"
    temporary=$(mktemp "$state_dir/.position.XXXXXX")
    printf '%s\n%s\n' "$workspace" "$bounds" > "$temporary"
    mv -- "$temporary" "$state_file"
    echo "Saved $bundle on workspace $workspace: $bounds"
    exit
fi

[[ -z "${AEROSPACE_FOCUSED_WORKSPACE:-}" || "$AEROSPACE_FOCUSED_WORKSPACE" == "$workspace" ]] || exit 0

# Import the earlier Telegram-only setting once, preserving it across this upgrade.
if [[ -f "$state_root/telegram-position.txt" && ! -f "$state_dir/ru.keepcoder.Telegram.txt" ]]; then
    umask 077
    mkdir -p "$state_dir"
    { printf 'E\n'; cat "$state_root/telegram-position.txt"; } > "$state_dir/ru.keepcoder.Telegram.txt"
    mv "$state_root/telegram-position.txt" "$state_root/telegram-position.migrated.txt"
fi

[[ -d "$state_dir" ]] || exit 0
sleep 0.5
shopt -s nullglob
for state_file in "$state_dir"/*.txt; do
    {
        IFS= read -r saved_workspace
        read -r x y width height
    } < "$state_file"
    [[ "$saved_workspace" == "$workspace" ]] || continue
    valid=true
    for value in "$x" "$y" "$width" "$height"; do
        [[ "$value" =~ ^-?[0-9]+$ ]] || valid=false
    done
    [[ "$valid" == true ]] || continue
    [[ "$("$aerospace_bin" list-workspaces --focused)" == "$workspace" ]] || exit 0
    bundle=${state_file##*/}
    bundle=${bundle%.txt}
    # Only restore apps actually managed on this workspace, without opening them.
    count=$("$aerospace_bin" list-windows --workspace "$workspace" --app-bundle-id "$bundle" --count)
    [[ "$count" == 1 ]] || continue
    /usr/bin/osascript "$script_dir/window-position.applescript" restore "$x" "$y" "$width" "$height" "$aerospace_bin" "$bundle" "$workspace" || continue
done
