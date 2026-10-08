# Zed Resterm

A thin Zed extension for [Resterm](https://github.com/unkn0wn-root/resterm).

The extension owns the editor integration only. Resterm remains the request parser and execution engine.

## Features

- `.http` and `.rest` syntax highlighting
- JSON and XML body injection
- runnable gutter action for each request
- `Resterm: Run all requests` task
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

Both tasks look for an environment file, checking the source `.http` directory first, then the Zed worktree root. Within each directory, the precedence is:

1. `http-client.env.json` (JetBrains-compatible name)
2. `rest-client.env.json`
3. `resterm.env.json`

When found, the task supplies `--env-file "<path>"` to Resterm. Resterm itself does not automatically discover `http-client.env.json`, but it can load it explicitly. Without a matching file, the normal Resterm CLI behavior remains unchanged.

Resterm chooses the default named environment according to its own rules; this extension does not add an environment picker or override that selection. Verify the active environment before executing mutating requests. To try this, open [examples/environment.http](examples/environment.http), which uses [examples/http-client.env.json](examples/http-client.env.json).

Only one environment file is loaded; `http-client.private.env.json` is **not** merged automatically. That would require additional semantics beyond Resterm's single-environment-file support.

## Notes

If another installed Zed extension also claims `.http` or `.rest`, disable it while testing to avoid language-association conflicts.

The stdin-backed request runs with a logical `stdin.http` under the workspace root, so relative body-file references may not resolve relative to the original `.http` file. The environment-variable transport also has platform size limits.

The HTTP grammar is pinned to [`feapps/tree-sitter-http`](https://github.com/feapps/tree-sitter-http), a small fork of `rest-nvim/tree-sitter-http` that fixes multiline query comments and tab-indented files.
