# Git commits

Write commit messages in English.

# Validation

This is a personal dotfiles repository. Run checks appropriate to the change locally. Add CI or Git hooks only when explicitly requested.

# Troubleshooting

Before changing behavior, investigate the cause of the reported problem and verify it with a focused check. Prefer fixing the cause when practical. Use a workaround when a direct fix is unavailable or disproportionately costly, and explain the tradeoff.

# Neovim configuration

When editing Neovim Lua configuration, use trailing comments for explanations of a single line of code, setting, or mapping. Place comments explaining an entire block on a separate line immediately above the block.

For every Neovim invocation, including `nvim --version` and `nvim --help`, set `NVIM_LOG_FILE` before launching the process: even version queries can create a log before configuration loads. Use a temporary directory with cleanup on exit:

```sh
(
  check_dir=$(mktemp -d) || exit 1
  trap 'rm -rf "$check_dir"' EXIT
  export NVIM_LOG_FILE="$check_dir/nvim.log"
  nvim --headless -n -i NONE -u NONE ...
  # Inspect any logs needed for diagnosis before leaving this subshell.
)
```

For checks that start the editor, pass `-n -i NONE` to disable swap and ShaDa writes. Before finishing, check for generated files in the working tree and remove artifacts created by your checks.
