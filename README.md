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

- **Minimal & Fast** - Focused on essentials, ~1200 LOC
- **mini.nvim Ecosystem** - File explorer, picker, completion, statusline, and more
- **LSP Ready** - Language servers via Mason (Lua, Python, TypeScript, C/C++)
- **GitHub Copilot** - Native inline completion support
- **Git Integration** - Fugitive + Gitsigns
- **Custom Colorscheme** - "Despair" theme with comprehensive coverage
- **Auto-formatting** - conform.nvim ready
- **Smart Keybinds** - Window navigation, tab management, buffer switching

## Core Keybindings

### Navigation
| Key | Action |
|-----|--------|
| `<C-hjkl>` | Move between splits |
| `<S-hl>` | Previous/next buffer |
| `<Tab>` / `<S-Tab>` | Next/previous tab |

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
| `<leader>e` | Toggle file explorer (mini.files) |
| `<leader>ff` | Find files (mini.pick) |
| `<leader>fg` | Live grep |
| `<leader>w` / `<leader>q` | Save / Quit |

### Copilot (Insert Mode)
| Key | Action |
|-----|--------|
| `<Tab>` | Accept suggestion |
| `<M-]>` | Next suggestion |
| `<M-[>` | Previous suggestion |

Use `:help keymaps.lua` for the complete list or press `<leader>` to see hints with mini.clue.

## Structure

```
.
├── init.lua                    # Entry point
├── lua/config/
│   ├── settings.lua            # Editor options
│   ├── plugins.lua             # Plugin bootstrap & list
│   ├── keymaps.lua             # Global keybindings
│   ├── lsp.lua                 # LSP setup
│   └── plugins/
│       ├── mini.lua            # mini.nvim modules config
│       └── copilot.lua         # GitHub Copilot native inline completion
└── colors/
    └── despair.lua             # Custom dark colorscheme
```

## Configuration

Edit files in `lua/config/` to customize behavior:

- **settings.lua** - Vim options (indentation, search, UI)
- **plugins.lua** - Add/remove plugins, bootstrap setup
- **lsp.lua** - Language servers, diagnostics, completion
- **keymaps.lua** - Global keybindings
- **plugins/mini.lua** - mini.nvim module configuration
- **plugins/copilot.lua** - GitHub Copilot native inline completion settings

## Notes

- Plugin installation is automatic via mini.deps
- Plugins are stored in `~/.local/share/nvim/site/pack/deps/`
- The configuration uses Neovim's native LSP (no vim-lsp needed)

## License

MIT - See LICENSE file
