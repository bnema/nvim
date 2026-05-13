# nvim-config

A minimal Neovim configuration built on [mini.nvim](https://github.com/echasnovski/mini.nvim).

**Status:** v0.1.0 (alpha)

## Requirements

- **Neovim:** 0.12 or later (native inline completion support)
- **Nerd Font:** Any [Nerd Font](https://www.nerdfonts.com/) (for icons and symbols)
- **Git:** Required for plugin management

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/nvim-config ~/.config/nvim
```

Launch Neovim:
```bash
nvim
```

## Features

- **Minimal & Fast** - Focused on essentials, KISS philosophy
- **mini.nvim Ecosystem** - File explorer, picker, completion, statusline, and more
- **LSP Ready** - Language servers via Mason (Lua, Python, TypeScript, Go, Svelte/SvelteKit)
- **GitHub Copilot** - Native inline completion support
- **Git Integration** - mini.git + mini.diff for staging, diffing, and navigation
- **Auto-formatting** - LSP-based formatting on save (Go, Svelte, TypeScript/JavaScript)
- **Smart Keybinds** - Window navigation and buffer switching
- **Buffer-first workflow** - No tab-page keymaps by default, just buffers and splits

## Core Keybindings

### Navigation
| Key | Action |
|-----|--------|
| `<C-hjkl>` | Move between splits |
| `<S-hl>` | Previous/next buffer |
| `<Tab>` / `<S-Tab>` | Next/previous buffer |
| `<leader>fb` | Pick an open buffer |

### LSP
| Key | Action |
|-----|--------|
| `gd` / `gD` | Go to definition/declaration |
| `gi` / `gr` | Go to implementation/references |
| `<leader>lh` | Hover |
| `<leader>la` | Code action |

### File Operations
| Key | Action |
|-----|--------|
| `<leader>e` | Open file explorer (root) |
| `<leader>E` | Open file explorer (cwd) |
| `<leader>fy` | Open Yazi file manager |
| `<leader>ff` | Find files (fzf-lua) |
| `<leader>fg` | Live grep |
| `<leader>w` / `<leader>q` | Save / Quit |

### Copilot (Insert Mode)
| Key | Action |
|-----|--------|
| `<Tab>` | Accept suggestion |
| `<M-]>` | Next suggestion |
| `<M-[>` | Previous suggestion |

This config is buffer-first: the top bar shows buffers, and no tab-page keymaps are enabled by default.

Use `:help keymaps.lua` for the complete list or press `<leader>` to see hints with mini.clue.

## Structure

```
.
├── init.lua                    # Entry point
├── lua/config/
│   ├── settings.lua            # Editor options
│   ├── native-packages.lua     # Native package management (vim.pack)
│   ├── keymaps.lua             # Global keybindings
│   ├── lsp.lua                 # LSP setup
│   ├── format.lua              # Auto-formatting configuration
│   └── plugins/
│       ├── mini.lua            # mini.nvim modules config
│       └── yazi.lua            # File manager integration
```

## Configuration

Edit files in `lua/config/` to customize behavior:

- **settings.lua** - Vim options (indentation, search, UI)
- **native-packages.lua** - Native vim.pack plugin management
- **lsp.lua** - Language servers, diagnostics, LSP keybindings
- **format.lua** - Auto-formatting on save configuration
- **keymaps.lua** - Global keybindings
- **plugins/mini.lua** - mini.nvim module configuration

- **plugins/yazi.lua** - Yazi file manager integration

## Notes

- Plugin installation is automatic via Neovim's native `vim.pack` system
- Plugins are stored in `~/.local/share/nvim/site/pack/`
- Uses Neovim's native LSP and inline completion (no external wrappers)
- Native Copilot requires the `copilot-language-server` binary to be installed separately
- Formatting is LSP-based (no external formatters like conform.nvim needed)

## License

MIT - See LICENSE file
