local util = require("formatter.util")

-- Helper function to check if executable exists
local function executable_exists(exe)
    if vim.fn.executable(exe) == 1 then
        return true
    end
    return false
end

local function executable_path(exe)
    local path = vim.fn.exepath(exe)
    if path ~= "" then
        return path
    end
    return nil
end

-- Helper function to get prettier
local function get_prettier()
    local prettier = executable_path("prettier")
    if prettier then
        return {
            exe = prettier,
            args = {
                "--stdin-filepath",
                util.escape_path(util.get_current_buffer_file_path()),
            },
            stdin = true,
            try_node_modules = true,
        }
    end
    return nil
end

require("formatter").setup({
  filetype = {
    javascript = {
      -- Prettier for JavaScript
      function()
        return get_prettier()
      end,
    },
    typescript = {
      -- Prettier for TypeScript
      function()
        return get_prettier()
      end,
    },
    typescriptreact = {
      -- Prettier for TSX
      function()
        return get_prettier()
      end,
    },
    javascriptreact = {
      -- Prettier for JSX
      function()
        return get_prettier()
      end,
    },
    json = {
      -- Prettier for JSON
      function()
        return get_prettier()
      end,
    },
    css = {
      -- Prettier for CSS
      function()
        return get_prettier()
      end,
    },
    html = {
      -- Prettier for HTML
      function()
        return get_prettier()
      end,
    },
    markdown = {
      -- Prettier for Markdown
      function()
        return get_prettier()
      end,
    },
    lua = {
      -- StyLua for Lua formatting
      function()
        local stylua = executable_path("stylua")
        if not stylua then
          return nil
        end

        return {
          exe = stylua,
          args = {
            "--search-parent-directories",
            "--stdin-filepath",
            util.escape_path(util.get_current_buffer_file_path()),
            "--",
            "-",
          },
          stdin = true,
        }
      end,
    },
  },
})

-- Format on save disabled - use :Format or <leader>f to format manually
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*",
--   callback = function()
--     -- Check if we have any formatters for this filetype
--     if not vim.tbl_isempty(require("formatter.config").values.filetype[vim.bo.filetype] or {}) then
--       vim.cmd("FormatWrite")
--     end
--   end,
-- })
