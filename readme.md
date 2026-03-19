# Samit’s Neovim Config

This is a heavily customized Neovim setup designed to deliver a **VS Code–level visual experience** with the **full power of Neovim’s keyboard-driven workflow**.

## Philosophy

The goal of this config is simple:  
combine **excellent code readability** with **maximum speed and control**.

After years of using VS Code, the biggest challenge when switching to Neovim wasn’t keybindings, it was readability. VS Code’s syntax highlighting is extremely polished, and you don’t fully appreciate it until you lose it. At the same time, even with Vim extensions, VS Code never truly matches the efficiency and fluidity of native Neovim.

## What This Config Focuses On

This setup is the result of months of work to bring the best of both worlds together:

- Clear, high-quality syntax highlighting  
- Fast, keyboard-first navigation and editing  
- Efficient search and file traversal  
- Smooth Git review workflows  

## Platform Support

Originally built on Linux Mint, this configuration has been adapted to run cleanly on **Windows 11** as well.

A Linux Mint version is still available for those who prefer it.

## Why this config is different

The biggest thing to understand about this setup is that the colors are not just a theme drop-in.

A lot of time went into making the editor feel right, especially for React, Next.js, TypeScript, TSX, and JavaScript. The syntax highlighting is the crown jewel of this config. It is not stock Tree-sitter. It is not stock LSP coloring. It is not just `vscode.nvim` with a few tweaks. It is a hand-tuned system that forces the exact visual separation that makes modern frontend code easy to read.

That includes things like:

- React component names staying teal/green instead of drifting into random colors
- useState hooks are highlighted just like it is in VS Code
- props and variables staying light blue
- bracket pair colorization that feels close to VS Code without wrecking TSX readability
- custom types/interfaces/classes staying green
- built-in types staying blue
- Better Comments-style markers like `//!`, `//TODO`, and `//*`

If you spend most of your time in React, Next.js, TS, TSX, or JS, this is where the config really separates itself. The highlighting work here is next level and honestly the kind of thing you usually do not find in public configs because it takes a ridiculous amount of trial, error, overrides, Tree-sitter query work, and LSP fighting to get right.

## What you get when Neovim opens

On startup, the config opens a custom Alpha dashboard with a `Samit` header (that you should change to your own name or whatever you like) and quick actions for:

- Projects
- Recent files
- Find file
- Quit

The rest of the setup is built to feel fast and focused:

- a VS Code-inspired Dark+ presentation with custom statusline, buffer tabs, and explorer styling
- Telescope for fuzzy finding and project navigation
- NvimTree for file browsing
- Spectre for VS Code-style search across files
- Gitsigns + LazyGit for a strong Git review workflow
- LSP, completion, formatting, spell checking, and filetype-specific polish

## Requirements

### Core dependencies

- Neovim
- Git
- Node.js and npm
- A Nerd Font in your terminal for icons

### Global npm packages

Install these globally:

```sh
npm install -g cspell prettier tree-sitter-cli typescript typescript-language-server @tailwindcss/language-server vscode-langservers-extracted
```

These power:

- `cspell` for code-aware spell checking
- `prettier` for JS/TS/TSX/JSON/CSS/HTML/Markdown formatting
- `tree-sitter-cli` for parser management
- `typescript` and `typescript-language-server` for TS/JS LSP support
- `@tailwindcss/language-server` for Tailwind IntelliSense
- `vscode-langservers-extracted` for HTML/CSS/JSON language servers

### Other external tools

These are also important if you want the full experience:

- `ripgrep` for Telescope and search speed
- `fd` for fast file finding
- `lazygit` for Git UI
- `lua-language-server`
- `gopls` if you want Go support
- `stylua` for Lua formatting
- `clang`/LLVM and `7zip` for a smooth Tree-sitter/Mason setup on Windows

On Windows, a solid baseline is:

```sh
winget install BurntSushi.ripgrep.MSVC sharkdp.fd JesseDuffield.lazygit LLVM.LLVM LuaLS.lua-language-server 7zip.7zip
go install golang.org/x/tools/gopls@latest
```

## Core workflows

Leader is mapped to `Space`.

### Files, projects, and navigation

| Key | Action |
| --- | --- |
| `<leader>ff` | Fuzzy find files |
| `<C-f>` | Fuzzy find files |
| `<C-p>` | Git-tracked file search |
| `<leader>fg` | Search text across files |
| `<leader>fb` | Open buffer list |
| `<leader>fh` | Help tags |
| `<leader>e` | Toggle file tree |
| `<leader><leader>` | Switch between the last two files |
| `p` on dashboard | Open projects |
| `r` on dashboard | Open recent files |
| `f` on dashboard | Find a file |

### File tree behavior

The file tree is tuned for an explorer-style workflow:

- `<Tab>` opens the selected file as a normal buffer while keeping focus in the tree
- `<S-Tab>` opens a preview
- `<C-l>` moves from the tree into the file window

This avoids the annoying preview-buffer disappearing behavior that some default tree setups have.

### Window management

| Key | Action |
| --- | --- |
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<C-h>` | Move left |
| `<C-l>` | Move right |
| `<C-j>` | Move down |
| `<C-k>` | Move up |
| `<leader>w=` | Equalize split sizes |
| `<leader>w]` | Increase window width |
| `<leader>w[` | Decrease window width |
| `<leader>x` | Close current window |

### Buffer tab system

This config uses Bufferline to make open buffers feel like editor tabs.

| Key | Action |
| --- | --- |
| `<leader>tab` | Close current tab/buffer |
| `<C-PageUp>` | Previous tab/buffer |
| `<C-PageDown>` | Next tab/buffer |
| `<C-S-PageUp>` | Move tab left |
| `<C-S-PageDown>` | Move tab right |
| `<leader>bn` | Fallback next buffer |
| `<leader>bp` | Fallback previous buffer |

### LSP, diagnostics, and formatting

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover info |
| `gi` | Go to implementation |
| `<leader>D` | Type definition |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>d` | Show diagnostic float |
| `<leader>q` | Send project errors to quickfix |
| `<leader>f` | Format current buffer |
| `<leader>rf` | Restart LSP |

Go gets special treatment:

- Go files format on save through `gopls`
- `gofumpt` is enabled for stricter formatting

### Search and replace

| Key | Action |
| --- | --- |
| `<leader>S` | Open project-wide Spectre search panel |
| `<leader>sw` | Search current word |
| `<leader>sp` | Search in current file |

Inside Spectre:

| Key | Action |
| --- | --- |
| `dd` | Toggle a result on/off |
| `<leader>R` | Replace all |
| `<leader>rc` | Replace current line |
| `<leader>q` | Send results to quickfix |

### Git workflow

| Key | Action |
| --- | --- |
| `<leader>gg` | Open LazyGit |
| `<leader>gf` | Open LazyGit file history |
| `<leader>gs` | Show changed files |
| `]c` / `[c` | Jump between hunks |
| `<leader>hp` | Preview hunk |
| `<leader>hP` | Preview hunk inline |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| Visual + `<leader>hs` | Stage selected lines |
| Visual + `<leader>hr` | Reset selected lines |
| `<leader>hS` | Stage entire buffer |
| `<leader>hR` | Reset entire buffer |
| `<leader>hu` | Undo last stage |
| `<leader>hb` | Show blame for line |
| `<leader>hd` | Diff current file |
| `<leader>td` | Toggle deleted lines |

### Spell checking and writing

This setup uses a hybrid spell workflow:

- native spell checking for prose files like Markdown and text
- `cspell` for code files

| Key | Action |
| --- | --- |
| `<leader>ss` | Toggle native spell |
| `<leader>sa` | Add word to CSpell dictionary |
| `]s` / `[s` | Next/previous misspelled word |
| `z=` | Suggestions |
| `zg` | Add word to native dictionary |

### Quality-of-life tweaks

- `Esc` clears search highlighting
- delete/change/replace actions go to the black hole register so they do not clobber your yank history
- `<leader>k` acts like a real cut when you actually want one
- `<C-d>` and `<C-u>` are remapped to smooth 1/3-page scrolling with cursor centering
- `n` and `N` keep search matches centered
- `gl` and `gL` add blank lines below/above without entering insert mode
- scroll offset is set so you keep breathing room above and below the cursor
- persistent undo is enabled

## Plugin overview

### UI and layout

- `Mofiqul/vscode.nvim` - base theme, then heavily overridden
- `goolord/alpha-nvim` - custom `Samit` dashboard
- `nvim-lualine/lualine.nvim` - custom statusline with Git blame and error-aware coloring
- `akinsho/bufferline.nvim` - VS Code-like tabs with custom colors
- `nvim-tree/nvim-tree.lua` - file explorer
- `nvim-tree/nvim-web-devicons` - file icons

### Code intelligence and editing

- `nvim-treesitter/nvim-treesitter` - parsing and syntax foundation
- `HiPhish/rainbow-delimiters.nvim` - bracket pair coloring
- `lukas-reineke/indent-blankline.nvim` - indentation guides
- `neovim/nvim-lspconfig` - LSP setup
- `williamboman/mason.nvim` and `mason-lspconfig.nvim` - server management
- `hrsh7th/nvim-cmp` + `LuaSnip` - completion/snippets
- `mhartington/formatter.nvim` - formatting for non-Go files
- `windwp/nvim-autopairs` - auto pairs
- `windwp/nvim-ts-autotag` - auto close and rename HTML/JSX tags

### Search and project flow

- `nvim-telescope/telescope.nvim` - fuzzy finder and picker engine
- `ahmedkhalf/project.nvim` - project detection
- `nvim-pack/nvim-spectre` - project-wide search/replace panel

### Git

- `lewis6991/gitsigns.nvim` - diff review and hunk actions
- `kdheepak/lazygit.nvim` - full-screen Git workflow
- `f-person/git-blame.nvim` - blame metadata in the statusline

### Writing and spelling

- `davidmh/cspell.nvim` - code spell checking
- `nvimtools/none-ls.nvim` - CSpell diagnostics/code actions bridge

### Extras

- `karb94/neoscroll.nvim` - smooth scrolling
- `ThePrimeagen/vim-be-good` - movement practice game

## The real secret sauce

If you want to understand why this setup looks different from a normal Neovim config, start here:

- `config/lazy.lua` - core settings, plugin bootstrap, theme overrides, keymaps
- `config/treesitter.lua` - Tree-sitter startup and Better Comments color groups
- `queries/typescript/highlights.scm` - custom TypeScript captures
- `queries/tsx/highlights.scm` - custom TSX captures
- `queries/javascript/highlights.scm` - custom JavaScript comment captures
- `queries/go/highlights.scm` - custom Go comment captures
- `config/lsp.lua` - LSP setup, semantic token shutdown, Go format-on-save
- `config/telescope.lua` - fuzzy finder behavior
- `config/nvim-tree.lua` - file tree behavior
- `config/gitsigns.lua` - Git review workflow
- `config/lualine.lua` - statusline behavior
- `config/formatter.lua` - formatting sources
- `cspell.json` - fallback code dictionary

The React/Next.js highlighting work in particular lives in a combination of theme overrides, LSP semantic token suppression, filetype-specific highlight forcing, and custom Tree-sitter queries. That is the part of this config that took the most effort and gives it the strongest identity.

## Getting started quickly

If you just cloned this config and want to feel what it is about:

1. Launch `nvim`
2. Start from the `Samit` dashboard
3. Press `p` for Projects or `<leader>ff` to find a file
4. Open the file tree with `<leader>e`
5. Search the project with `<leader>S`
6. Open LazyGit with `<leader>gg`
7. Open a React or Next.js file and look closely at the colors

That last step is where this config really shows off.
