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

Open a `.http` or `.rest` file and use the gutter run button next to a request. The extension executes:

```sh
resterm run --line "$ZED_ROW" "$ZED_FILE"
```

The current buffer is saved before the command runs, so Resterm sees the latest contents.

You can also open **task: spawn** and choose **Resterm: Run all requests**.

## Notes

If another installed Zed extension also claims `.http` or `.rest`, disable it while testing to avoid language-association conflicts.

The HTTP grammar is pinned to [`feapps/tree-sitter-http`](https://github.com/feapps/tree-sitter-http), a small fork of `rest-nvim/tree-sitter-http` that fixes multiline query comments and tab-indented files.
