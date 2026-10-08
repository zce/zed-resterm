# Zed Resterm

A thin Zed extension for [Resterm](https://github.com/unkn0wn-root/resterm).

The extension owns the editor integration only. Resterm remains the request parser and execution engine.

## Features

- `.http` and `.rest` syntax highlighting
- JSON and XML body injection
- runnable gutter action for each request
- `Resterm: Run all requests` task
- dynamic per-worktree environment selection through Zed's Task Picker or a named-task keybinding
- no Rust, LSP, Node.js, or bundled sidecar

## Requirements

Install `resterm` and make sure it is available on `PATH`:

```sh
resterm --version
```

## Install for development

Clone this repository, then in Zed run **zed: install dev extension** and select the repository root.

Open a `.http` or `.rest` file and use the gutter run button next to a request. The extension passes the **current editor buffer**, including unsaved changes, through a task environment variable to Resterm stdin. It does **not** save the file.

You can also open **task: spawn** and choose **Resterm: Run all requests**. This separate task saves the current file and runs all requests from disk.

## Environment files

Both run tasks look for an environment file, checking the source `.http` directory first, then the Zed worktree root. Within each directory, the precedence is:

1. `http-client.env.json` (JetBrains-compatible name)
2. `rest-client.env.json`
3. `resterm.env.json`

When found, the task supplies `--env-file "<path>"` to Resterm. Resterm itself does not automatically discover `http-client.env.json`, but it can load it explicitly. Without a matching file, normal Resterm CLI behavior remains unchanged unless an explicit environment was selected.

To switch environments, run **Resterm: Switch Environment** from Zed's **task: spawn** picker. The picker reads the available environment names **dynamically** from the discovered environment file, so no names are hard-coded. Use **Up/Down** (or **j/k**) and **Enter** to select; **Esc** cancels. Select **Automatic** to clear the saved selection and use Resterm's default. The current selection is marked with `*`. The environment picker uses a temporary tab, which Zed closes after the task exits, including after canceling. It is not kept as a separate output tab.

For direct access without opening the generic Task Picker, assign a shortcut in your Zed `keymap.json`:

```json
[
  {
    "context": "Workspace && !Terminal",
    "bindings": {
      "alt-e": ["task::Spawn", { "task_name": "Resterm: Switch Environment", "reveal_target": "dock" }]
    }
  }
]
```

Zed's extension API currently does **not** let third-party extensions register arbitrary Command Palette actions or native picker dialogs. This is a named Task invoked directly via Zed's built-in action, not an independently registered Command Palette command. The temporary terminal picker uses Python 3's standard-library curses support (required only when switching environments, not when running requests).

The choice applies to both gutter **Run request** and **Run all requests**. Zed reuses task terminal tabs by full task label. Both gutter runs and **Run all requests** now share the same **Resterm** tab. The gutter task is tagged (and therefore hidden from the generic Task Picker), while the visible **Resterm** task in that picker runs **all** requests — review mutating requests before selecting it. The environment picker is a separate temporary task because it needs keyboard input; its terminal closes when that task exits. Zed has no independent terminal reuse-group setting. It is stored per worktree under `${XDG_STATE_HOME:-~/.local/state}/zed-resterm/` (keyed by the worktree path), not in the repository. Only the environment *name* is saved; secrets and variable values are not.

An explicitly selected environment that isn't in the environment file fails instead of silently choosing a different one. If no file was found, an explicit selection also fails. With **Automatic** (the initial state), Resterm chooses `dev`, `default`, or `local` if present, otherwise the first named environment. The picker handles flat named-environment files, not Resterm's `$groups` format. Verify the environment shown in the run output before executing mutating requests.

See [examples/environment.http](examples/environment.http) and [examples/http-client.env.json](examples/http-client.env.json).

Only one environment file is loaded; `http-client.private.env.json` is **not** merged automatically. That would require additional semantics beyond Resterm's single-environment-file support.

## Notes

If another installed Zed extension also claims `.http` or `.rest`, disable it while testing to avoid language-association conflicts.

The stdin-backed request runs with a logical `stdin.http` under the workspace root, so relative body-file references may not resolve relative to the original `.http` file. The environment-variable transport also has platform size limits.

The HTTP grammar is pinned to [`feapps/tree-sitter-http`](https://github.com/feapps/tree-sitter-http), a small fork of `rest-nvim/tree-sitter-http` that fixes multiline query comments and tab-indented files.
