import * as path from 'path';
import * as vscode from 'vscode';

type PathStyle = 'fileName' | 'relative' | 'absolute';

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

// VS Code lines are 0-indexed; add 1 to match the gutter.
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

  return startLine === endLine ? `${startLine}` : `${startLine}-${endLine}`;
}

async function copyAsMention(style: PathStyle): Promise<void> {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    void vscode.window.showWarningMessage('Copy as Mention: no active editor.');
    return;
  }

  const range = renderLineRange(editor.selection);
  const text = `@${renderPath(editor.document, style)}${range && `#${range}`}`;

  await vscode.env.clipboard.writeText(text);
  vscode.window.setStatusBarMessage(`Copied: ${text}`, 2000);
}

export function activate(context: vscode.ExtensionContext): void {
  const commands: Array<[string, PathStyle]> = [
    ['copyAsMention.copyRelative', 'relative'],
    ['copyAsMention.copyFileName', 'fileName'],
    ['copyAsMention.copyAbsolute', 'absolute'],
  ];

  for (const [commandId, style] of commands) {
    context.subscriptions.push(
      vscode.commands.registerCommand(commandId, () => copyAsMention(style)),
    );
  }
}
