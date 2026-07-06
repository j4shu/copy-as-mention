# Copy as Mention

A tiny VS Code extension that copies the active file's path plus the currently
selected line range to your clipboard as a **Claude Code `@`-mention** — so you
can look at code in VS Code, then paste a precise reference straight into a
Claude Code terminal session.

The format mirrors Claude Code's VS Code `@`-mention syntax
(`@<path>#<start>-<end>`). Pasting it into the Claude Code prompt lets Claude
resolve it into the actual file and lines.

## What it copies

| Situation                             | Copied text         |
| ------------------------------------- | ------------------- |
| Multi-line selection in `src/foo.txt` | `@src/foo.txt#1-39` |
| Single line selected                  | `@src/foo.txt#5`    |
| No selection (just a cursor)          | `@src/foo.txt`      |

Line numbers are 1-indexed to match the editor gutter. The `@` prefix, `#` path
separator, and `-` range separator are fixed.

## Usage

There are three commands, one per path style:

| Command                       | Copied path                              |
| ----------------------------- | ---------------------------------------- |
| **Copy as Mention: Relative** | Relative to the workspace root (default) |
| **Copy as Mention: Filename** | Just the file name                       |
| **Copy as Mention: Absolute** | Full absolute path                       |

Run any of them via **right-click** in the editor or the **Command Palette**.

Only **Relative** has a default keyboard shortcut:
`Cmd+Alt+C` (macOS) / `Ctrl+Alt+C` (Windows/Linux). Bind the others yourself in
_Preferences → Keyboard Shortcuts_ if you want.

Then paste into your Claude Code terminal prompt.

## Settings

| Setting                              | Default | Description                                                |
| ------------------------------------ | ------- | ---------------------------------------------------------- |
| `copyAsMention.showStatusBarMessage` | `true`  | Show a brief confirmation in the status bar after copying. |

## Install

The extension is automatically built from the latest commit on `main`.

Download `copy-as-mention.vsix` from the
[latest release](../../releases/latest), then run:

```bash
code --install-extension copy-as-mention.vsix
```

(or Extensions panel → `…` → _Install from VSIX…_).
