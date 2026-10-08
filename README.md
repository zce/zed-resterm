# Zed Resterm

A thin [Zed](https://zed.dev) extension for [Resterm](https://github.com/unkn0wn-root/resterm). Resterm owns request parsing and execution; the extension provides syntax highlighting and editor tasks. No Rust, LSP, or bundled sidecar.

## Features

- `.http` / `.rest` highlighting, with JSON and XML body injection
- Gutter action to execute the current request from the **unsaved editor buffer**
- Run every request in the saved file
- Switch environments dynamically using the names in the loaded environment file
- **One reusable `Resterm` terminal tab** for all three operations

## Requirements

Install `resterm` on your `PATH`:

```sh
resterm --version
```

Environment switching additionally requires Python 3 with `curses` support; running requests does not.

## Install for development

Clone this repository and in Zed run **zed: install dev extension** on its root.

Open a `.http` or `.rest` file. The gutter run button executes the request with the current unsaved editor text. The task passes the editor buffer through an environment variable to Resterm stdin; it does not save the file.

All three tasks intentionally have the **same label** (`Resterm`) so Zed reuses their terminal tab. Their distinct **tags** identify each operation:

| Tag | Action |
| --- | --- |
| `resterm-request` | Run request at the gutter (bound automatically) |
| `resterm-all` | Save the current file and run all requests |
| `resterm-switch` | Choose an environment from the current environment file |

Because task labels are identical, **do not use `task: spawn` by name** to choose among them; Zed does not treat tags as display names. Assign the actions you want to Zed shortcuts using `task_tag`, for example in `keymap.json`:

```json
[
  {
    "context": "Workspace && !Terminal",
    "bindings": {
      "alt-e": ["task::Spawn", { "task_tag": "resterm-switch" }],
      "alt-shift-e": ["task::Spawn", { "task_tag": "resterm-all" }]
    }
  }
]
```

Environment switching uses Up/Down (or j/k), Enter to confirm, and Esc to cancel. The picker remains in the shared `Resterm` tab on exit. Running another task **replaces** that tab's previous contents; it does not preserve response history or keep the previous process alive.

## Environment files

Both execution tasks and the environment picker discover the first matching file, checking the active `.http` directory before the Zed worktree root. File name precedence in each directory:

1. `http-client.env.json` (JetBrains-compatible)
2. `rest-client.env.json`
3. `resterm.env.json`

The run tasks pass `--env-file` explicitly when a file is found, so `http-client.env.json` works even though Resterm does not auto-discover it.

The picker reads **named environments** from the file (no hard-coded `dev`/`prod` list). **Automatic** clears the selection and restores Resterm's default behavior. The selected environment name is saved per worktree in `${XDG_STATE_HOME:-~/.local/state}/zed-resterm/` and passed to later runs with `--env`. If the chosen environment is missing, Resterm fails instead of silently falling back. The picker currently supports flat named environments, not Resterm's `$groups` format.

See [examples/environment.http](examples/environment.http) and [examples/http-client.env.json](examples/http-client.env.json). `http-client.private.env.json` is not merged automatically.

## Limitations

- Zed cannot currently register extension-defined Command Palette actions or dynamically populated native pickers; these operations use built-in tasks selected by tag.
- For stdin requests, Resterm treats input as `stdin.http` at the workspace root, so relative body-file paths may not resolve relative to the opened file.
- Transporting the unsaved buffer through a task environment variable has an OS-dependent size limit.
- If another installed Zed extension also registers `.http` / `.rest`, disable it when testing to avoid file-association conflicts.

The HTTP grammar is pinned to [feapps/tree-sitter-http](https://github.com/feapps/tree-sitter-http).
