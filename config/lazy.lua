-- 1️⃣ Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function prepend_to_path(dir)
  if not dir or dir == "" or vim.fn.isdirectory(dir) == 0 then
    return
  end

  local normalized = vim.fs.normalize(dir)
  local path_sep = vim.fn.has("win32") == 1 and ";" or ":"
  local current_path = vim.env.PATH or ""

  for entry in string.gmatch(current_path, "[^" .. path_sep .. "]+") do
    if vim.fs.normalize(entry):lower() == normalized:lower() then
      return
    end
  end

  vim.env.PATH = normalized .. path_sep .. current_path
end

if vim.fn.has("win32") == 1 then
  prepend_to_path("C:/Program Files/Git/usr/bin")
  prepend_to_path("C:/Program Files/Git/cmd")
  prepend_to_path(vim.fn.stdpath("data") .. "/mason/bin")
  prepend_to_path(vim.fn.getenv("LOCALAPPDATA") .. "/Microsoft/WinGet/Links")
  prepend_to_path(vim.fn.getenv("APPDATA") .. "/npm")
  prepend_to_path((vim.uv or vim.loop).os_homedir() .. "/go/bin")
  prepend_to_path("C:/Program Files/LLVM/bin")
  prepend_to_path("C:/Program Files/7-Zip")
end

-- 2️⃣ Core settings (from your LunarVim config)
vim.o.termguicolors = true
vim.g.mapleader = " "
vim.o.relativenumber = true
vim.o.number = true
vim.o.cursorline = true
vim.o.scrolloff = 5  -- Keep 5 lines above/below cursor when scrolling
vim.o.signcolumn = "yes"
vim.opt.fixeol = false    -- Don't automatically add a newline at the end of the file
vim.opt.eol = false       -- Don't write a newline if there isn't one already

-- ═══════════════════════════════════════════════════════════════
-- DISABLE LSP SEMANTIC TOKENS GLOBALLY (NUCLEAR OPTION)
-- ═══════════════════════════════════════════════════════════════
-- This runs BEFORE any LSP starts, ensuring semantic tokens never activate
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

-- Clipboard: use the system clipboard when a provider is available
vim.o.clipboard = "unnamedplus"

-- Set Ctrl+U/D scroll to 1/3 of window height
local function set_scroll_third()
  local height = vim.api.nvim_win_get_height(0)
  vim.opt.scroll = math.floor(height / 3)
end

vim.api.nvim_create_autocmd({ "WinEnter", "VimResized" }, {
  callback = set_scroll_third,
})

-- Persistent undo (undo even after closing file)
vim.opt.undofile = true

-- Ask for confirmation instead of erroring (e.g., :q on unsaved file)
vim.opt.confirm = true

-- Disable swap files
vim.opt.swapfile = false

-- Search settings
vim.opt.hlsearch = true      -- Highlight search results
vim.opt.incsearch = true     -- Show matches while typing
vim.opt.ignorecase = true    -- Case insensitive search...
vim.opt.smartcase = true     -- ...unless uppercase is used

-- Auto-clear search highlights when pressing Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Send delete/change/replace to black hole register (don't overwrite clipboard)
vim.keymap.set('n', 'd', '"_d', { noremap = true })
vim.keymap.set('v', 'd', '"_d', { noremap = true })
vim.keymap.set('n', 'D', '"_D', { noremap = true })
vim.keymap.set('n', 'c', '"_c', { noremap = true })
vim.keymap.set('v', 'c', '"_c', { noremap = true })
vim.keymap.set('n', 'C', '"_C', { noremap = true })
vim.keymap.set('n', 'x', '"_x', { noremap = true })
vim.keymap.set('v', 'x', '"_x', { noremap = true })
vim.keymap.set('n', 's', '"_s', { noremap = true })
vim.keymap.set('v', 's', '"_s', { noremap = true })
-- Use leader+j to cut (delete to clipboard) when you actually want to cut
vim.keymap.set('n', '<leader>k', 'd', { noremap = true })
vim.keymap.set('v', '<leader>k', 'd', { noremap = true })

-- Native spell settings (fallback for prose)
vim.o.spelllang = "en_us"
vim.o.spellsuggest = "best,9"  -- Show 9 best suggestions

-- Fix Indentation (4 spaces)
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

-- Set for all buffer types
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.expandtab = true
  end
})

-- Disable netrw completely
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Filetype detection
vim.cmd([[autocmd BufRead,BufNewFile *.tsx set filetype=typescriptreact]])
vim.cmd([[autocmd BufRead,BufNewFile *.jsx set filetype=javascriptreact]])

-- 3️⃣ Helper function to load config files
local function load_config(config_name)
  local config_path = vim.fn.stdpath("config") .. "/config/" .. config_name .. ".lua"
  if vim.fn.filereadable(config_path) == 1 then
    dofile(config_path)
  else
    vim.notify("Config file not found: " .. config_path, vim.log.levels.WARN)
  end
end

-- 4️⃣ Load plugins
require("lazy").setup({
  -- 💻 VS Code Dark+ theme
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      local c = require('vscode.colors').get_colors()
      require('vscode').setup({
        style = 'dark',
        transparent = false,
        italic_comments = true,
        underline_links = true,
        disable_nvimtree_bg = true,
        color_overrides = {
          vscBack = '#000000',
          vscTabCurrent = '#000000',
          vscTabOther = '#000000',
          vscTabOutside = '#000000',
        },
      })
      require('vscode').load()

      -- ═══════════════════════════════════════════════════════════════
      -- VS Code Dark+ EXACT color mappings for TypeScript/TSX/JSX
      -- ═══════════════════════════════════════════════════════════════
      
      -- VS Code Dark+ color palette
      local colors = {
        blue = "#569CD6",           -- keywords, type keyword, arrow =>
        light_blue = "#9CDCFE",     -- variables, parameters
        dark_blue = "#4FC1FF",      -- constants
        green = "#4EC9B0",          -- types, classes, interfaces
        light_green = "#B5CEA8",    -- numbers
        yellow = "#DCDCAA",         -- functions, methods
        orange = "#CE9178",         -- strings
        purple = "#C586C0",         -- control flow, import/export
        white = "#D4D4D4",          -- default text
        gray = "#808080",           -- comments, tag delimiters
        yellow_orange = "#D7BA7D",  -- decorators, special
        -- VS Code bracket pair colorization colors (cycling)
        bracket_1 = "#FFD700",      -- Gold (level 1)
        bracket_2 = "#DA70D6",      -- Orchid/Purple (level 2)
        bracket_3 = "#179FFF",      -- Blue (level 3)
      }

      -- Keywords
      vim.api.nvim_set_hl(0, "@keyword", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@keyword.type", { fg = colors.blue })           -- type, interface
      vim.api.nvim_set_hl(0, "@keyword.function", { fg = colors.blue })       -- function, async
      vim.api.nvim_set_hl(0, "@keyword.return", { fg = colors.purple })       -- return
      vim.api.nvim_set_hl(0, "@keyword.operator", { fg = colors.blue })       -- typeof, keyof
      vim.api.nvim_set_hl(0, "@keyword.import", { fg = colors.purple })       -- import, export
      vim.api.nvim_set_hl(0, "@keyword.export", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "@keyword.conditional", { fg = colors.purple })  -- if, else
      vim.api.nvim_set_hl(0, "@keyword.repeat", { fg = colors.purple })       -- for, while
      vim.api.nvim_set_hl(0, "@include", { fg = colors.purple })              -- import/from
      vim.api.nvim_set_hl(0, "@conditional", { fg = colors.purple })

      -- Types (green in VS Code)
      vim.api.nvim_set_hl(0, "@type", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@type.builtin", { fg = colors.blue })           -- void, string, number, boolean
      vim.api.nvim_set_hl(0, "@type.definition", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@type.qualifier", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@storageclass", { fg = colors.blue })           -- const, let, var

      -- Functions (yellow in VS Code)
      vim.api.nvim_set_hl(0, "@function", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "@function.call", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "@function.builtin", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "@method", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "@method.call", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "@constructor", { fg = colors.green })           -- new ClassName()

      -- Variables and parameters (light blue in VS Code)
      vim.api.nvim_set_hl(0, "@variable", { fg = colors.light_blue })
      vim.api.nvim_set_hl(0, "@variable.builtin", { fg = colors.blue })       -- this, self
      vim.api.nvim_set_hl(0, "@variable.parameter", { fg = colors.light_blue })
      vim.api.nvim_set_hl(0, "@parameter", { fg = colors.light_blue })
      vim.api.nvim_set_hl(0, "@property", { fg = colors.light_blue })
      vim.api.nvim_set_hl(0, "@field", { fg = colors.light_blue })

      -- Constants
      vim.api.nvim_set_hl(0, "@constant", { fg = colors.dark_blue })
      vim.api.nvim_set_hl(0, "@constant.builtin", { fg = colors.blue })       -- true, false, null
      vim.api.nvim_set_hl(0, "@boolean", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@number", { fg = colors.light_green })
      vim.api.nvim_set_hl(0, "@float", { fg = colors.light_green })

      -- Strings
      vim.api.nvim_set_hl(0, "@string", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "@string.escape", { fg = colors.yellow_orange })
      vim.api.nvim_set_hl(0, "@string.regex", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "@character", { fg = colors.orange })

      -- Operators - arrow function => should be BLUE in VS Code
      vim.api.nvim_set_hl(0, "@operator", { fg = colors.blue })               -- =>, =, +, -, etc.

      -- Punctuation (default - will be overridden by rainbow brackets plugin)
      vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = colors.bracket_1 }) -- {} () []
      vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = colors.white }) -- , ; :
      vim.api.nvim_set_hl(0, "@punctuation.special", { fg = colors.blue })    -- template literals ${}

      -- JSX/TSX specific
      vim.api.nvim_set_hl(0, "@tag", { fg = colors.blue })                    -- HTML tags
      vim.api.nvim_set_hl(0, "@tag.builtin", { fg = colors.blue })            -- div, span, etc.
      vim.api.nvim_set_hl(0, "@tag.component", { fg = colors.green })         -- React components
      vim.api.nvim_set_hl(0, "@tag.attribute", { fg = colors.light_blue })    -- props
      vim.api.nvim_set_hl(0, "@tag.delimiter", { fg = colors.gray })          -- < > />

      -- For TSX components (PascalCase = component)
      vim.api.nvim_set_hl(0, "@lsp.type.class.typescriptreact", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.type.typescriptreact", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.interface.typescriptreact", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.enum.typescriptreact", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.enumMember.typescriptreact", { fg = colors.dark_blue })

      -- LSP semantic tokens (these override treesitter when LSP is active)
      vim.api.nvim_set_hl(0, "@lsp.type.class", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.type", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.interface", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.enumMember", { fg = colors.dark_blue })
      vim.api.nvim_set_hl(0, "@lsp.type.function", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "@lsp.type.method", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = colors.light_blue })
      vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = colors.light_blue })
      vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = colors.light_blue })
      vim.api.nvim_set_hl(0, "@lsp.type.keyword", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@lsp.type.namespace", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.decorator", { fg = colors.yellow_orange })
      vim.api.nvim_set_hl(0, "@lsp.type.typeParameter", { fg = colors.green })

      -- TypeScript specific semantic tokens
      vim.api.nvim_set_hl(0, "@lsp.type.class.typescript", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.type.typescript", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.interface.typescript", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.typemod.variable.readonly", { fg = colors.dark_blue })
      vim.api.nvim_set_hl(0, "@lsp.typemod.property.readonly", { fg = colors.dark_blue })

      -- Built-in types (void, string, number, boolean, any, never, etc.)
      vim.api.nvim_set_hl(0, "TSTypeBuiltin", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@type.builtin.typescript", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@type.builtin.typescriptreact", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@type.builtin.tsx", { fg = colors.blue })

      -- Ensure operators (including =>) are blue
      vim.api.nvim_set_hl(0, "@operator.typescript", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@operator.typescriptreact", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@operator.tsx", { fg = colors.blue })

      -- ═══════════════════════════════════════════════════════════════
      -- FORCE REACT COMPONENT TEAL (Fixes Golden & Purple Tags)
      -- ═══════════════════════════════════════════════════════════════

      -- Force ALL custom components to Teal/Green
      vim.api.nvim_set_hl(0, "@tag.component", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@tag.component.tsx", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@tag.component.typescriptreact", { fg = colors.green })

      -- Override the groups causing the "Golden" color
      vim.api.nvim_set_hl(0, "@constructor.tsx", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@constructor.typescriptreact", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@variable.tsx", { fg = colors.green }) -- Fixes Header/Card
      vim.api.nvim_set_hl(0, "@type.tsx", { fg = colors.green })     -- Fixes ErrorMessage

      -- Override the groups causing the "Purple" color for tags
      vim.api.nvim_set_hl(0, "@type.builtin.tsx", { fg = colors.blue }) -- Fixes <span, <div
      vim.api.nvim_set_hl(0, "@type.qualifier.tsx", { fg = colors.blue })

      -- Fix the "Blue" X import (force it to light blue like other variables)
      vim.api.nvim_set_hl(0, "@constant.tsx", { fg = colors.light_blue }) 

      -- Ensure standard tags stay Blue
      vim.api.nvim_set_hl(0, "@tag.tsx", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@tag.builtin.tsx", { fg = colors.blue })
      
      -- Ensure props/attributes stay Light Blue
      vim.api.nvim_set_hl(0, "@tag.attribute.tsx", { fg = colors.light_blue })
      vim.api.nvim_set_hl(0, "@tag.attribute.typescriptreact", { fg = colors.light_blue })
      
      -- Delimiters
      vim.api.nvim_set_hl(0, "@tag.delimiter.tsx", { fg = colors.gray })
      vim.api.nvim_set_hl(0, "@tag.delimiter.typescriptreact", { fg = colors.gray })
      
      -- ═══════════════════════════════════════════════════════════════
      -- NUCLEAR HIGHLIGHT FORCE - Use force=true to override everything
      -- ═══════════════════════════════════════════════════════════════
      
      -- 1. Create a function to force our colors
      local function force_tsx_colors()
          local green = "#4EC9B0"      -- VS Code Teal/Green
          local blue = "#569CD6"       -- VS Code HTML Blue
          local light_blue = "#9CDCFE" -- VS Code Variable Light Blue
          local gray = "#808080"       -- VS Code Gray

          -- ═══════════════════════════════════════════════════════════════
          -- NUCLEAR OPTION: FORCE ALL @lsp.* TYPE HIGHLIGHTS TO GREEN
          -- ═══════════════════════════════════════════════════════════════
          -- Instead of clearing, we FORCE every @lsp type-related highlight to green
          local lsp_type_patterns = {
            "type", "class", "interface", "struct", "enum", "typeParameter",
            "typeAlias", "namespace"
          }
          for _, pattern in ipairs(lsp_type_patterns) do
            vim.api.nvim_set_hl(0, "@lsp.type." .. pattern, { fg = green })
            vim.api.nvim_set_hl(0, "@lsp.type." .. pattern .. ".typescript", { fg = green })
            vim.api.nvim_set_hl(0, "@lsp.type." .. pattern .. ".typescriptreact", { fg = green })
          end
          
          -- Also handle modifiers
          vim.api.nvim_set_hl(0, "@lsp.typemod.type.declaration", { fg = green })
          vim.api.nvim_set_hl(0, "@lsp.typemod.type.defaultLibrary", { fg = green })
          vim.api.nvim_set_hl(0, "@lsp.typemod.interface.declaration", { fg = green })
          vim.api.nvim_set_hl(0, "@lsp.typemod.class.declaration", { fg = green })
          vim.api.nvim_set_hl(0, "@lsp.typemod.enum.declaration", { fg = green })
          vim.api.nvim_set_hl(0, "@lsp.typemod.typeParameter.declaration", { fg = green })

          -- ═══════════════════════════════════════════════════════════════
          -- 1. UNIVERSAL TYPE LINKS (This fixes the white types)
          -- ═══════════════════════════════════════════════════════════════
          -- This links every "Type" related group to the VS Code Green
          local all_type_groups = {
              "Type", "StorageClass", "Structure", "Typedef",
              "@type", "@type.tsx", "@type.typescript", "@type.typescriptreact",
              "@type.definition", "@type.builtin", "@type.qualifier",
              "@lsp.type.type", "@lsp.type.interface", "@lsp.type.class",
              "@lsp.type.enum", "@lsp.type.typeParameter",
              "@lsp.type.typeAlias", "@lsp.type.struct",
              "@lsp.typemod.type.defaultLibrary", "@lsp.typemod.type.declaration",
              "typescriptType", "typescriptTypeName", "typescriptInterfaceName",
              "typescriptClassName", "typescriptEnumName", "typescriptAliasDeclaration",
              "@type.definition.tsx", "@type.definition.typescriptreact",
              "@lsp.mod.declaration", "@lsp.mod.defaultLibrary",
          }
          for _, group in ipairs(all_type_groups) do
              vim.api.nvim_set_hl(0, group, { fg = green, force = true })
          end

          -- ═══════════════════════════════════════════════════════════════
          -- 2. RESET BUILT-INS TO BLUE (string, number, boolean)
          -- ═══════════════════════════════════════════════════════════════
          -- We do this AFTER the green loop so these stay blue like VS Code
          local builtin_types = {
              "@type.builtin.tsx", "@type.builtin.typescript",
              "typescriptPredefinedType", "tsxPredefinedType"
          }
          for _, group in ipairs(builtin_types) do
              vim.api.nvim_set_hl(0, group, { fg = blue, force = true })
          end

          -- ═══════════════════════════════════════════════════════════════
          -- 3. IMPORT NAMES (Light Blue)
          -- ═══════════════════════════════════════════════════════════════
          -- In VS Code, the name in { } is often light blue
          vim.api.nvim_set_hl(0, "@variable.tsx", { fg = light_blue, force = true })
          vim.api.nvim_set_hl(0, "@variable.typescript", { fg = light_blue, force = true })
          vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = light_blue, force = true })
          vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = light_blue, force = true })

          -- ═══════════════════════════════════════════════════════════════
          -- 4. JSX COMPONENTS (Keep them Teal/Green)
          -- ═══════════════════════════════════════════════════════════════
          vim.api.nvim_set_hl(0, "@tag.component.tsx", { fg = green, force = true })
          vim.api.nvim_set_hl(0, "@tag.component.typescriptreact", { fg = green, force = true })
          vim.api.nvim_set_hl(0, "@constructor.tsx", { fg = green, force = true })
          vim.api.nvim_set_hl(0, "@constructor.typescriptreact", { fg = green, force = true })

          -- ═══════════════════════════════════════════════════════════════
          -- 5. HTML TAGS (main, div, span)
          -- ═══════════════════════════════════════════════════════════════
          vim.api.nvim_set_hl(0, "@tag.tsx", { fg = blue, force = true })
          vim.api.nvim_set_hl(0, "@tag.builtin.tsx", { fg = blue, force = true })
          vim.api.nvim_set_hl(0, "@tag.delimiter.tsx", { fg = gray, force = true })
          
          -- ═══════════════════════════════════════════════════════════════
          -- 6. TYPESCRIPT TYPE REFERENCES (PascalCase types)
          -- ═══════════════════════════════════════════════════════════════
          -- If it starts with a capital letter and isn't a keyword, try to make it Green
          vim.api.nvim_set_hl(0, "typescriptTSType", { fg = green, force = true })
          vim.api.nvim_set_hl(0, "typescriptTypeReference", { fg = green, force = true })
          
          -- ═══════════════════════════════════════════════════════════════
          -- 7. GIT BLAME (Subtle Gray for Lualine)
          -- ═══════════════════════════════════════════════════════════════
          vim.api.nvim_set_hl(0, "lualine_c_gitblame", { fg = "#606060", italic = true })
      end

      -- Run it immediately and on every event that could change highlights
      force_tsx_colors()
      
      -- Run on colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", { callback = force_tsx_colors })
      
      -- Run when TypeScript/TSX files are opened or entered
      vim.api.nvim_create_autocmd({"FileType", "BufEnter", "BufWinEnter"}, {
          pattern = {"typescript", "typescriptreact", "javascript", "javascriptreact"},
          callback = force_tsx_colors
      })
      
      -- Run after LSP attaches (this is critical!)
      vim.api.nvim_create_autocmd("LspAttach", {
          callback = function()
              -- Force colors immediately after LSP attaches
              force_tsx_colors()
              
              -- Also force them again after a short delay (LSP might apply colors after attach)
              vim.defer_fn(force_tsx_colors, 100)
          end
      })
      
      -- Nuclear option: Run on every cursor move in TS files (disable if it causes lag)
      -- vim.api.nvim_create_autocmd("CursorHold", {
      --     pattern = {"*.ts", "*.tsx", "*.js", "*.jsx"},
      --     callback = force_tsx_colors
      -- })

      
      -- ═══════════════════════════════════════════════════════════════
      -- THE WHITE TYPES KILL-SWITCH (Final Boss Fix)
      -- ═══════════════════════════════════════════════════════════════

      -- 1. Target general TypeScript/TSX types
      vim.api.nvim_set_hl(0, "@type.typescript", { fg = "#4EC9B0", force = true })
      vim.api.nvim_set_hl(0, "@type.tsx", { fg = "#4EC9B0", force = true })

      -- 2. Target LSP Semantic tokens (This is why your custom types are white)
      -- Even if provider is nil, some tokens still leak through or need explicit linking
      local lsp_type_groups = {
          "@lsp.type.type",
          "@lsp.type.interface",
          "@lsp.type.class",
          "@lsp.type.enum",
          "@lsp.type.typeParameter",
          "@lsp.typemod.type.default_library",
      }

      for _, group in ipairs(lsp_type_groups) do
          vim.api.nvim_set_hl(0, group, { fg = "#4EC9B0", force = true })
      end

      -- 3. Fix standard built-in types (string, number, etc.) to be Blue
      vim.api.nvim_set_hl(0, "@type.builtin.typescript", { fg = "#569CD6", force = true })
      vim.api.nvim_set_hl(0, "@type.builtin.tsx", { fg = "#569CD6", force = true })
      
      -- ═══════════════════════════════════════════════════════════════
      -- Fix CursorLine Flickering (Prevents white tags on cursor line)
      -- ═══════════════════════════════════════════════════════════════
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2a2d2e" }) -- Subtle dark grey background
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = blue, bold = true }) -- Blue line number
      vim.o.cursorlineopt = "number,screenline" -- Prevent syntax color override
    end,
  },

  -- Custom statusline (Lualine)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "Mofiqul/vscode.nvim" },
    config = function()
      load_config("lualine")
    end,
  },

  -- Git blame for status line
  {
    "f-person/git-blame.nvim",
    config = function()
      -- Disable the virtual text (the text that appears next to code)
      vim.g.gitblame_enabled = 0 -- We only want the data for lualine
      vim.g.gitblame_display_virtual_text = 0 
      -- Set the date format to relative (e.g., "10 days ago")
      vim.g.gitblame_date_format = '%r'
      -- Customize the message format to just Author and Time
      vim.g.gitblame_message_template = '<author> • <date>'
    end
  },

  -- File explorer (NvimTree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      load_config("nvim-tree")
    end,
  },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup {
        default = true,
        strict = true,
        override = {
          default_icon = { icon = "", color = "#6c6c6c", name = "Default" },
        }
      }
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      load_config("telescope")
    end,
  },

  -- Project-wide search & replace (VS Code-like search panel)
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local sed_path = vim.fn.exepath("sed")

      require("spectre").setup({
        highlight = {
          ui = "String",
          search = "DiffChange",
          replace = "DiffDelete",
        },
        default = {
          find = {
            cmd = "rg",
            options = { "ignore-case" },
          },
          replace = {
            cmd = "sed",
          },
        },
        replace_engine = {
          sed = {
            cmd = sed_path ~= "" and sed_path or "sed",
            warn = false,
          },
        },
        mapping = {
          ['toggle_line'] = {
            map = "dd",
            cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
            desc = "toggle item"
          },
          ['enter_file'] = {
            map = "<cr>",
            cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
            desc = "open file"
          },
          ['send_to_qf'] = {
            map = "<leader>q",
            cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
            desc = "send all items to quickfix"
          },
          ['replace_cmd'] = {
            map = "<leader>c",
            cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
            desc = "input replace command"
          },
          ['show_option_menu'] = {
            map = "<leader>o",
            cmd = "<cmd>lua require('spectre').show_options()<CR>",
            desc = "show options"
          },
          ['run_current_replace'] = {
            map = "<leader>rc",
            cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
            desc = "replace current line"
          },
          ['run_replace'] = {
            map = "<leader>R",
            cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
            desc = "replace all"
          },
          ['toggle_live_update'] = {
            map = "tu",
            cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
            desc = "update when vim writes to file"
          },
          ['resume_last_search'] = {
            map = "<leader>l",
            cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
            desc = "repeat last search"
          },
        },
      })

      -- Keymaps for opening Spectre
      vim.keymap.set("n", "<leader>S", function()
        require("spectre").open()
      end, { desc = "Project search (Spectre)" })

      vim.keymap.set("n", "<leader>sw", function()
        require("spectre").open_visual({ select_word = true })
      end, { desc = "Search current word" })

      vim.keymap.set("v", "<leader>sw", function()
        require("spectre").open_visual()
      end, { desc = "Search selection" })

      vim.keymap.set("n", "<leader>sp", function()
        require("spectre").open_file_search({ select_word = true })
      end, { desc = "Search in current file" })
    end,
  },

  -- LazyGit integration (Git UI like VS Code Source Control but better)
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit current file history" },
    },
    config = function()
      -- Floating window settings
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_floating_window_use_plenary = 1
    end,
  },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern", "lsp" },
        patterns = { ".git", "Makefile", "package.json" },
      })
      require("telescope").load_extension("projects")
    end,
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    lazy = false,
    priority = 900,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "███████╗ █████╗ ███╗   ███╗██╗████████╗",
        "██╔════╝██╔══██╗████╗ ████║██║╚══██╔══╝",
        "███████╗███████║██╔████╔██║██║   ██║   ",
        "╚════██║██╔══██║██║╚██╔╝██║██║   ██║   ",
        "███████║██║  ██║██║ ╚═╝ ██║██║   ██║   ",
        "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝   ╚═╝   ",
        "",
      }

      dashboard.section.buttons.val = {
        dashboard.button("p", "📁  Projects", ":Telescope projects<CR>"),
        dashboard.button("r", "🕘  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("f", "🔍  Find file", ":Telescope find_files<CR>"),
        dashboard.button("q", "⏻  Quit", ":qa<CR>"),
      }

      dashboard.section.footer.val = "grind ⚙️ → code 💻 → level up 🚀"

      -- Center everything
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "Keyword"
      dashboard.section.footer.opts.hl = "Comment"
      
      -- Set custom header color to blue (was changed by Type highlight override)
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#569CD6", bold = true })

      -- Layout with padding for centering
      dashboard.config.layout = {
        { type = "padding", val = 8 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        dashboard.section.footer,
      }

      alpha.setup(dashboard.config)
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Auto close HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup({
        autotag = {
          enable = true,
          enable_rename = true,
          enable_close = true,
          enable_close_on_slash = true,
          filetypes = {
            'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact'
          }
        }
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",  -- Use master branch for 2025 version
    lazy = false,
    build = ":TSUpdate",
    config = function()
      load_config("treesitter")
    end,
  },

  -- Rainbow brackets (VS Code bracket pair colorization)
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')

      -- VS Code bracket pair colorization colors
      vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#FFD700" })  -- Gold
      vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#DA70D6" })  -- Orchid
      vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#179FFF" })    -- Blue

      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
          -- Using 'rainbow-parens' is safer for React to avoid highlighting tag text
          tsx = 'rainbow-parens',
          typescript = 'rainbow-parens',
          javascript = 'rainbow-parens',
        },
        priority = {
          [''] = 110,
          lua = 210,
        },
        highlight = {
          'RainbowDelimiterYellow',
          'RainbowDelimiterViolet',
          'RainbowDelimiterBlue',
        },
      }
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",  -- Vertical line character
          tab_char = "│",
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = true,
          highlight = { "Function", "Label" },
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
          },
        },
      })
    end,
  },

  -- LSP + Mason
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        automatic_installation = true
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      load_config("lsp")
    end
  },

  -- Completion
  { 
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      load_config("cmp")
    end
  },

  -- Snippets
  { "L3MON4D3/LuaSnip" },

  -- Formatter
  {
    "mhartington/formatter.nvim",
    config = function()
      load_config("formatter")
    end,
  },

  -- Bufferline (buffer tabs like VS Code)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          show_buffer_close_icons = true,
          show_close_icon = true,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            -- Only show indicator for errors, not warnings/hints
            if diagnostics_dict.error and diagnostics_dict.error > 0 then
              return ""
            end
            return ""
          end,
          indicator = {
            style = "icon",
            icon = "▎",
          },
          modified_icon = "●",
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true,
            },
          },
        },
        highlights = {
          fill = { bg = "#000000" },
          -- Inactive tabs: grey text and background
          background = { fg = "#808080", bg = "#2d2d2d" },
          buffer_visible = { fg = "#808080", bg = "#2d2d2d" },
          close_button = { fg = "#808080", bg = "#2d2d2d" },
          close_button_visible = { fg = "#808080", bg = "#2d2d2d" },
          -- Active tab: black background, blue text
          buffer_selected = { fg = "#569cd6", bg = "#000000", bold = true, italic = false },
          close_button_selected = { fg = "#569cd6", bg = "#000000" },
          -- Separators
          separator = { fg = "#000000", bg = "#2d2d2d" },
          separator_selected = { fg = "#000000", bg = "#000000" },
          separator_visible = { fg = "#000000", bg = "#2d2d2d" },
          -- Tabs with errors: red text (inactive has grey bg, active has black bg)
          error = { fg = "#f44747", bg = "#2d2d2d" },
          error_visible = { fg = "#f44747", bg = "#2d2d2d" },
          error_selected = { fg = "#f44747", bg = "#000000", bold = true },
          error_diagnostic = { fg = "#f44747", bg = "#2d2d2d" },
          error_diagnostic_visible = { fg = "#f44747", bg = "#2d2d2d" },
          error_diagnostic_selected = { fg = "#f44747", bg = "#000000" },
          -- Warnings: same as normal (grey) - no special color
          warning = { fg = "#808080", bg = "#2d2d2d" },
          warning_visible = { fg = "#808080", bg = "#2d2d2d" },
          warning_selected = { fg = "#569cd6", bg = "#000000", bold = true },
          warning_diagnostic = { fg = "#808080", bg = "#2d2d2d" },
          warning_diagnostic_visible = { fg = "#808080", bg = "#2d2d2d" },
          warning_diagnostic_selected = { fg = "#569cd6", bg = "#000000" },
          -- Hints/Info: same as normal (grey)
          hint = { fg = "#808080", bg = "#2d2d2d" },
          hint_visible = { fg = "#808080", bg = "#2d2d2d" },
          hint_selected = { fg = "#569cd6", bg = "#000000", bold = true },
          hint_diagnostic = { fg = "#808080", bg = "#2d2d2d" },
          hint_diagnostic_visible = { fg = "#808080", bg = "#2d2d2d" },
          hint_diagnostic_selected = { fg = "#569cd6", bg = "#000000" },
          info = { fg = "#808080", bg = "#2d2d2d" },
          info_visible = { fg = "#808080", bg = "#2d2d2d" },
          info_selected = { fg = "#569cd6", bg = "#000000", bold = true },
          info_diagnostic = { fg = "#808080", bg = "#2d2d2d" },
          info_diagnostic_visible = { fg = "#808080", bg = "#2d2d2d" },
          info_diagnostic_selected = { fg = "#569cd6", bg = "#000000" },
          -- Modified indicator
          modified = { fg = "#808080", bg = "#2d2d2d" },
          modified_visible = { fg = "#808080", bg = "#2d2d2d" },
          modified_selected = { fg = "#569cd6", bg = "#000000" },
          -- Duplicate (same filename in different folders)
          duplicate = { fg = "#808080", bg = "#2d2d2d", italic = true },
          duplicate_visible = { fg = "#808080", bg = "#2d2d2d", italic = true },
          duplicate_selected = { fg = "#569cd6", bg = "#000000", italic = true },
          -- Indicator
          indicator_selected = { fg = "#569cd6", bg = "#000000" },
          indicator_visible = { fg = "#2d2d2d", bg = "#2d2d2d" },
        },
      })

      -- Keymaps with fallback alternatives for terminal compatibility
      local function run_bufferline(command, fallback)
        local ok = pcall(vim.cmd, command)
        if not ok and fallback then
          vim.cmd(fallback)
        end
      end

      local function is_tree_buffer(bufnr)
        return bufnr
          and bufnr > 0
          and vim.api.nvim_buf_is_valid(bufnr)
          and vim.bo[bufnr].filetype == "NvimTree"
      end

      local function is_editor_buffer(bufnr)
        return bufnr
          and bufnr > 0
          and vim.api.nvim_buf_is_valid(bufnr)
          and vim.bo[bufnr].buflisted
          and vim.bo[bufnr].buftype == ""
          and not is_tree_buffer(bufnr)
      end

      local function pick_buffer_to_close()
        local current_buf = vim.api.nvim_get_current_buf()
        if is_editor_buffer(current_buf) then
          return current_buf
        end

        local alternate_buf = vim.fn.bufnr("#")
        if is_editor_buffer(alternate_buf) then
          return alternate_buf
        end

        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local win_buf = vim.api.nvim_win_get_buf(win)
          if is_editor_buffer(win_buf) then
            return win_buf
          end
        end

        return nil
      end

      local function pick_replacement_buffer(closing_buf)
        local alternate_buf = vim.fn.bufnr("#")
        if alternate_buf ~= closing_buf and is_editor_buffer(alternate_buf) then
          return alternate_buf
        end

        local buffers = {}
        for _, bufinfo in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
          if bufinfo.bufnr ~= closing_buf and is_editor_buffer(bufinfo.bufnr) then
            table.insert(buffers, bufinfo)
          end
        end

        table.sort(buffers, function(a, b)
          return a.lastused > b.lastused
        end)

        return buffers[1] and buffers[1].bufnr or nil
      end

      local function pick_target_window()
        local current_win = vim.api.nvim_get_current_win()
        if not is_tree_buffer(vim.api.nvim_win_get_buf(current_win)) then
          return current_win
        end

        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if not is_tree_buffer(vim.api.nvim_win_get_buf(win)) then
            return win
          end
        end

        return current_win
      end

      local function close_buffer_tab()
        local closing_buf = pick_buffer_to_close()
        if not closing_buf then
          vim.cmd("enew")
          return
        end

        if vim.bo[closing_buf].modified then
          vim.notify("Save or discard changes before closing this buffer.", vim.log.levels.WARN)
          return
        end

        local target_win = pick_target_window()
        local replacement_buf = pick_replacement_buffer(closing_buf)

        vim.api.nvim_set_current_win(target_win)

        if replacement_buf then
          vim.api.nvim_win_set_buf(target_win, replacement_buf)
        else
          vim.cmd("enew")
        end

        vim.cmd("bdelete " .. closing_buf)
      end

      vim.keymap.set("n", "<C-PageDown>", function()
        run_bufferline("BufferLineCycleNext", "bnext")
      end, { desc = "Next buffer tab", silent = true })

      vim.keymap.set("n", "<C-PageUp>", function()
        run_bufferline("BufferLineCyclePrev", "bprev")
      end, { desc = "Previous buffer tab", silent = true })

      vim.keymap.set("n", "<C-S-PageDown>", function()
        run_bufferline("BufferLineMoveNext")
      end, { desc = "Move tab right", silent = true })

      vim.keymap.set("n", "<C-S-PageUp>", function()
        run_bufferline("BufferLineMovePrev")
      end, { desc = "Move tab left", silent = true })
      
      -- Fallback navigation (works in all terminals)
      vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer", silent = true })
      vim.keymap.set("n", "<leader>bp", ":bprev<CR>", { desc = "Previous buffer", silent = true })
      
      vim.keymap.set("n", "<leader><Tab>", close_buffer_tab, { desc = "Close buffer", silent = true })
      vim.keymap.set("n", "<leader>tab", close_buffer_tab, { desc = "Close buffer", silent = true })
    end,
  },

  -- Practice game
  {
    "ThePrimeagen/vim-be-good",
    config = function()
      -- Game is ready to use!
    end,
  },

  -- CSpell (VS Code-like spell checking for code)
  {
    "davidmh/cspell.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- null-ls for cspell integration
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "davidmh/cspell.nvim",
    },
    config = function()
      local null_ls = require("null-ls")
      local cspell = require("cspell")

      -- Global fallback cspell.json in nvim config
      local global_cspell = vim.fn.stdpath("config") .. "/cspell.json"

      -- CSpell config options
      local cspell_config = {
        -- Find cspell.json in project root, fallback to global
        find_json = function(cwd)
          -- Check project root first
          local path = vim.fn.findfile("cspell.json", cwd .. ";")
          if path ~= "" then
            return path
          end
          -- Try .cspell.json
          path = vim.fn.findfile(".cspell.json", cwd .. ";")
          if path ~= "" then
            return path
          end
          -- Fallback to global nvim config
          if vim.fn.filereadable(global_cspell) == 1 then
            return global_cspell
          end
          return nil
        end,
      }

      null_ls.setup({
        debug = true,  -- Enable debug logging
        sources = {
          -- Diagnostics: show spelling errors
          cspell.diagnostics.with({
            timeout = 10000,  -- 10 second timeout for large files
            diagnostics_postprocess = function(diagnostic)
              diagnostic.severity = vim.diagnostic.severity.WARN  -- Changed from HINT to WARN
            end,
            config = cspell_config,
          }),
          -- Code actions: add to dictionary
          cspell.code_actions.with({
            config = cspell_config,
          }),
        },
        on_attach = function(client, bufnr)
          -- Optionally set up any buffer-specific keymaps or settings
        end,
      })
    end,
  },

  {
    "karb94/neoscroll.nvim",
    config = function()
      require('neoscroll').setup({
        duration_multiplier = 1.0,
        easing_function = "quadratic",
        stop_eof = true,
      })
    end,
  },
})

-- Keymaps from your LunarVim config
vim.keymap.set("n", "<C-s>", ":w<cr>")
vim.keymap.set("n", "<C-f>", ":Telescope find_files<cr>")
vim.keymap.set("n", "<C-p>", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>rf", ":LspRestart<cr>")
vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<cr>")
vim.keymap.set("n", "gr", ":lua vim.lsp.buf.references()<cr>")

-- Switch between last two files
vim.keymap.set("n", "<leader><leader>", "<C-^>", { desc = "Switch to last buffer" })

-- Window splitting
vim.keymap.set("n", "<leader>sv", ":vsplit<cr>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<cr>", { desc = "Split window horizontally" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })

-- Window resizing
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>w]", ":vertical resize +5<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<leader>w[", ":vertical resize -5<CR>", { desc = "Decrease window width" })

-- Close current window
vim.keymap.set("n", "<leader>x", ":close<CR>", { desc = "Close current window" })

-- Debugging command for font issues
vim.keymap.set("n", "<leader>df", function()
    print("Testing Nerd Fonts...")
    print("Folder icons should appear below:")
    print("  (closed folder)")
    print("  (open folder)")
    print("  (empty folder)")
    print("  (open empty folder)")
end, { desc = "Debug fonts" })

-- Smooth scroll down and center cursor
vim.keymap.set('n', '<C-d>', function()
  require('neoscroll').ctrl_d({ duration = 400, done_callback = function() vim.cmd("normal! zz") end })
end, { desc = "Smooth scroll down and center" })

-- Smooth scroll half-page up and center cursor
vim.keymap.set('n', '<C-u>', function()
  require('neoscroll').ctrl_u({ duration = 400, done_callback = function() vim.cmd("normal! zz") end })
end, { desc = "Smooth scroll up and center" })

-- Keep cursor centered during search navigation
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search match (centered)" })

-- Add a new line BELOW current line without entering Insert mode
vim.keymap.set("n", "gl", "<cmd>call append(line('.'), repeat([''], v:count1))<CR>", { desc = "Add newline below" })

-- Add a new line ABOVE current line without entering Insert mode
vim.keymap.set("n", "gL", "<cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", { desc = "Add newline above" })

---------------------------------------------------------------------
-- SPELL CHECKING (Native + CSpell hybrid)
---------------------------------------------------------------------

-- Toggle native spell for prose files (Markdown, text, comments)
vim.keymap.set("n", "<leader>ss", ":set spell!<CR>", { desc = "Toggle spell check" })

-- Spell navigation
vim.keymap.set("n", "]s", "]s", { desc = "Next misspelled word" })
vim.keymap.set("n", "[s", "[s", { desc = "Previous misspelled word" })
vim.keymap.set("n", "z=", "z=", { desc = "Spelling suggestions" })
vim.keymap.set("n", "zg", "zg", { desc = "Add word to dictionary" })
vim.keymap.set("n", "zw", "zw", { desc = "Mark word as wrong" })

-- Auto-enable native spell for prose files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit", "plaintex", "tex" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
  desc = "Enable spell checking for prose files",
})

-- CSpell: Apply code action to add word to dictionary
vim.keymap.set("n", "<leader>sa", function()
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.title:match("Add.*to.*dictionary") or action.title:match("cspell")
    end,
    apply = true,
  })
end, { desc = "Add word to CSpell dictionary" })
