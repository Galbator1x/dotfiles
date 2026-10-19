# Git commits

Write commit messages in English.

# User environment

The user uses iTerm2 on macOS. Use iTerm2 when giving terminal-specific instructions; the Ghostty configuration in this repository does not indicate the active terminal.

# Neovim configuration

When editing Neovim Lua configuration, use trailing comments for explanations of a single line of code, setting, or mapping. Place comments explaining an entire block on a separate line immediately above the block.

When running Neovim checks, set `NVIM_LOG_FILE` to a file in a temporary directory before startup and pass `-n -i NONE` to disable swap and ShaDa writes. For example: `check_dir=$(mktemp -d); NVIM_LOG_FILE="$check_dir/nvim.log" nvim --headless -n -i NONE -u NONE ...`. Inspect any logs needed for diagnosis, then remove the temporary directory after the check.
