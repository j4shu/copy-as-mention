# Change Log

## [0.0.1]

- Initial release: copy the active file as a Claude Code `@`-mention
  (`@path#start-end`, or just `@path` with no selection) via right-click,
  keyboard shortcut, or the Command Palette.
- Fixed format mirroring Claude Code's VS Code `@`-mention syntax:
  workspace-relative path, `#` before the range, `-` between line numbers
  (e.g. `@src/foo.txt#1-39`).
- Configurable path style and status-bar confirmation.
