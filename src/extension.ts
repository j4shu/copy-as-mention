import * as path from 'path';
import * as vscode from 'vscode';

type PathStyle = 'fileName' | 'relative' | 'absolute';

// Fixed, non-configurable format that mirrors the Claude Code VS Code
// "@"-mention syntax: "@<path>#<start>-<end>" (e.g. "@src/foo.txt#1-39").
// The "@" lets Claude Code resolve it into the actual file/lines; "#" precedes
// the range, and a dash separates the line numbers.
const MENTION_PREFIX = '@';
const PATH_SEPARATOR = '#';
const RANGE_SEPARATOR = '-';

/**
 * Render the document's path according to the user's configured style.
 */
function renderPath(document: vscode.TextDocument, style: PathStyle): string {
  const fsPath = document.uri.fsPath;

  // Untitled / virtual documents have no real fs path; fall back to a label.
  if (document.isUntitled || !fsPath) {
    return document.uri.path.split('/').pop() || 'untitled';
  }

  switch (style) {
    case 'absolute':
      return fsPath;
    case 'fileName':
      return path.basename(fsPath);
    case 'relative':
    default:
      // asRelativePath returns the absolute path unchanged when the file is
      // outside every workspace folder, which is a sensible fallback.
      return vscode.workspace.asRelativePath(document.uri, false);
  }
}

/**
 * Build the line-range suffix for a selection.
 *
 * VS Code positions are 0-indexed, so we add 1 to match the gutter.
 * A single line yields "5"; a multi-line range yields "1-39".
 * Returns an empty string when the selection is just a cursor (empty).
 */
function renderLineRange(selection: vscode.Selection): string {
  if (selection.isEmpty) {
    return '';
  }

  const startLine = selection.start.line + 1;
  let endLine = selection.end.line + 1;

  // If the selection ends at column 0 of a line, that trailing line isn't
  // really "included" (the user dragged to the start of the next line).
  // Pull the end back by one, but never below the start line.
  if (selection.end.character === 0 && endLine > startLine) {
    endLine -= 1;
  }

  return startLine === endLine ? `${startLine}` : `${startLine}${RANGE_SEPARATOR}${endLine}`;
}

export function activate(context: vscode.ExtensionContext): void {
  const disposable = vscode.commands.registerCommand('copyAsMention.copy', async () => {
    const editor = vscode.window.activeTextEditor;
    if (!editor) {
      void vscode.window.showWarningMessage('Copy as Mention: no active editor.');
      return;
    }

    const config = vscode.workspace.getConfiguration('copyAsMention');
    const pathStyle = config.get<PathStyle>('pathStyle', 'relative');
    const showStatusBarMessage = config.get<boolean>('showStatusBarMessage', true);

    const renderedPath = renderPath(editor.document, pathStyle);
    const range = renderLineRange(editor.selection);
    const reference = `${MENTION_PREFIX}${renderedPath}`;
    const text = range ? `${reference}${PATH_SEPARATOR}${range}` : reference;

    await vscode.env.clipboard.writeText(text);

    if (showStatusBarMessage) {
      vscode.window.setStatusBarMessage(`Copied: ${text}`, 2000);
    }
  });

  context.subscriptions.push(disposable);
}

export function deactivate(): void {
  // No cleanup required.
}
