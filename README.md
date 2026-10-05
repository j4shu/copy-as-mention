# Copy as Mention

A tiny VS Code extension that copies the active file's path with the currently
selected line range to your clipboard as a **Claude Code `@`-mention**
(`@<path>#<start>-<end>`).

## What it copies

| Situation                             | Copied text         |
| ------------------------------------- | ------------------- |
| Multi-line selection in `src/foo.txt` | `@src/foo.txt#1-39` |
| Single line selected                  | `@src/foo.txt#5`    |
| No selection (just a cursor)          | `@src/foo.txt`      |

## Usage

There are three commands, one per path style:

| Command                       | Copied path                              |
| ----------------------------- | ---------------------------------------- |
| **Copy as Mention: Relative** | Relative to the workspace root (default) |
| **Copy as Mention: Absolute** | Full absolute path                       |
| **Copy as Mention: Filename** | File name                                |

Run any of them via **right-click** in the editor or the **Command Palette**.

## Install

Download `copy-as-mention.vsix` from the
[latest release](../../releases/latest), then run:

```bash
code --install-extension copy-as-mention.vsix
```

(or Extensions panel → `…` → _Install from VSIX…_).
