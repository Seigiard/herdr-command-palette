# Herdr Command Palette

A dependency-light Herdr command palette for user-owned commands. It keeps the
command catalog outside the plugin checkout, supports deterministic aliases
before fuzzy title search, and includes safe pane/tab dispatch, forms, selects,
workspace switching, and smart close.

## Requirements

- Herdr 0.7.0 or newer
- Python 3.9 or newer
- fzf 0.56 or newer
- macOS or Linux

`git` is needed only for repository-scoped commands and `{project_root}`. Zed
and lazygit are optional tools used only by commands that name them.

## Install

```bash
herdr plugin install Seigiard/herdr-command-palette --ref v0.1.0 -y
herdr plugin enable seigi.command-palette
```

Use an immutable tag or commit with `--ref` in managed environments. To update,
review a newer release, change the ref, and run the same install command. To
remove the plugin while preserving user configuration and state:

```bash
herdr plugin uninstall seigi.command-palette
```

The plugin never creates or rewrites command configuration.

## Configuration

The default catalog is one user-owned file:

```text
~/.config/herdr/command-palette/commands.toml
```

Set `HERDR_COMMAND_PALETTE_CONFIG` to test another file. Sibling `*.toml` files
are supported but optional.

```toml
[[commands]]
group = "Git"
title = "Lazygit"
shortcuts = ["lg"]
type = "tab_run"
command = "lazygit"

[[commands]]
group = "Checks"
title = "Lint dotfiles"
repositories = ["Seigiard/my-mac-setup"]
type = "shell"
command = "make -C {project_root_q} lint"
pause = true
```

`repositories` matches a normalized `origin` URL such as
`git@github.com:Seigiard/my-mac-setup.git` or
`https://github.com/Seigiard/my-mac-setup.git`. This keeps project commands in
the same user file and does not add files to repositories. Existing optional
`.herdr/command-palette/*.toml` files remain read-only compatibility inputs.

Validate configuration without opening the UI:

```bash
python3 palette.py --validate ~/.config/herdr/command-palette/commands.toml
```

## Command Types

- `herdr`: invoke Herdr with an argv array.
- `pane_run`: run a shell command in the pane that opened the palette.
- `tab_run`: create a tab and run a command there.
- `shell`: run in the popup and optionally pause for output.
- `overlay_shell`: replace the popup with an interactive command.
- `plugin_action`: invoke another plugin action.
- `workspace_picker`: choose and focus a workspace.
- `select`: choose a static or dynamically generated value, then run a nested command.
- `form`: collect text, then run a nested command.

Shell-bearing commands reject a bare `{value}` during validation. Use
`{value_q}` for shell quoting or `{value_url}` for URL encoding. Other context
placeholders include `{config_file}`, `{config_dir}`, `{plugin_root}`,
`{state_dir}`, `{target_pane}`, `{target_cwd}`, and `{project_root}`; each path
also has a `_q` form.

Search ranks case-insensitive exact and prefix `shortcuts` before fuzzy title
matches. Groups and descriptions are display-only and cannot displace a stable
shortcut.

## Actions

- `seigi.command-palette.open`: open or focus the palette popup.
- `seigi.command-palette.smart_close`: close a pane, then a tab, but never the
  final tab in a workspace.

The manifest also provides `palette` and `lazygit` pane entrypoints.

## Development

```bash
make lint
make test
herdr plugin link "$PWD" --enabled
```

The behavior suite uses Bashunit 0.50.1, vendored under `tests/lib/` with its
MIT license notice retained in `THIRD_PARTY_NOTICES.md`.
