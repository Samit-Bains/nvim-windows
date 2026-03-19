-- Configure diagnostic signs and display
vim.diagnostic.config({
  virtual_text = true,  -- Show diagnostic messages next to the code
  signs = true,         -- Show signs in the sign column
  underline = true,     -- Underline the problem area
  update_in_insert = false,  -- Wait until leaving insert mode to update diagnostics
  severity_sort = true,      -- Sort diagnostics by severity
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Define diagnostic symbols
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Configure LSP floating windows background
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2D2D2D", fg = "#CCCCCC" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#2D2D2D", fg = "#CCCCCC" })

-- Configure hover window handler with custom border
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
  }
)

-- Configure signature help handler with custom border
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = "rounded",
  }
)

-- Enable LSP capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local go_format_augroup = vim.api.nvim_create_augroup("GoFormatOnSave", { clear = false })

-- Common on_attach function for LSP keymaps
local on_attach = function(client, bufnr)
  -- ═══════════════════════════════════════════════════════════════
  -- COMPLETELY DISABLE LSP SEMANTIC TOKENS (Nuclear Option)
  -- ═══════════════════════════════════════════════════════════════
  -- Method 1: Disable the provider
  client.server_capabilities.semanticTokensProvider = nil
  
  -- Method 2: Stop any running semantic token requests
  if client.supports_method("textDocument/semanticTokens/full") then
    vim.lsp.semantic_tokens.stop(bufnr, client.id)
  end
  
  -- Method 3: Clear ALL @lsp highlights to let Tree-sitter win
  for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
  end

  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
  
  -- Diagnostic keymaps
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Previous diagnostic" })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next diagnostic" })
  vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { buffer = bufnr, desc = "Show diagnostic error messages" })
  vim.keymap.set('n', '<leader>q', function()
    vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
  end, { buffer = bufnr, desc = "Open errors list (all files)" })

  if client.name == "gopls" and client:supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = go_format_augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = go_format_augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          timeout_ms = 3000,
          filter = function(format_client)
            return format_client.name == "gopls"
          end,
        })
      end,
      desc = "Format Go files on save",
    })
  end
end

-- Use vim.lsp.config for nvim-lspconfig v3.0.0-pre
-- TypeScript/JavaScript configuration (ts_ls replaces deprecated tsserver)
vim.lsp.config('ts_ls', {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
})

-- Lua configuration
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- TailwindCSS configuration
vim.lsp.config('tailwindcss', {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
})

-- HTML configuration
vim.lsp.config('html', {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "html" },
})

-- CSS configuration
vim.lsp.config('cssls', {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "css", "scss", "less" },
})

-- Go configuration
vim.lsp.config('gopls', {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

-- Enable the LSP servers
vim.lsp.enable("ts_ls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("gopls")
