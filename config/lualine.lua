-- Top of lualine.lua
local git_blame_ok, git_blame = pcall(require, "gitblame")

-- Define fallback functions if the plugin isn't loaded yet
if not git_blame_ok then
    git_blame = {
        get_current_blame_text = function() return "" end,
        is_blame_text_available = function() return false end
    }
end

-- Function to determine theme based on diagnostics
local function get_lualine_theme()
  local has_errors = false
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  
  if #diagnostics > 0 then
    has_errors = true
  end
  
  if has_errors then
    -- Red theme when errors are present
    return {
      normal = {
        a = { fg = '#ffffff', bg = '#ff0000', gui = 'bold' },
        b = { fg = '#ffffff', bg = '#ff0000' },
        c = { fg = '#ffffff', bg = '#ff0000' },
      },
      insert = {
        a = { fg = '#ffffff', bg = '#ff0000', gui = 'bold' },
        b = { fg = '#ffffff', bg = '#ff0000' },
        c = { fg = '#ffffff', bg = '#ff0000' },
      },
      visual = {
        a = { fg = '#ffffff', bg = '#ff0000', gui = 'bold' },
        b = { fg = '#ffffff', bg = '#ff0000' },
        c = { fg = '#ffffff', bg = '#ff0000' },
      },
      replace = {
        a = { fg = '#ffffff', bg = '#ff0000', gui = 'bold' },
        b = { fg = '#ffffff', bg = '#ff0000' },
        c = { fg = '#ffffff', bg = '#ff0000' },
      },
      command = {
        a = { fg = '#ffffff', bg = '#ff0000', gui = 'bold' },
        b = { fg = '#ffffff', bg = '#ff0000' },
        c = { fg = '#ffffff', bg = '#ff0000' },
      },
      inactive = {
        a = { fg = '#ffffff', bg = '#ff0000' },
        b = { fg = '#ffffff', bg = '#ff0000' },
        c = { fg = '#ffffff', bg = '#ff0000' },
      },
    }
  else
    -- VS Code Dark+ inspired theme when no errors
    return {
      normal = {
        a = { fg = '#000000', bg = '#569cd6', gui = 'bold' },
        b = { fg = '#d4d4d4', bg = '#252526' },
        c = { fg = '#808080', bg = '#1e1e1e' },
      },
      insert = {
        a = { fg = '#000000', bg = '#6a9955', gui = 'bold' },
        b = { fg = '#d4d4d4', bg = '#252526' },
        c = { fg = '#808080', bg = '#1e1e1e' },
      },
      visual = {
        a = { fg = '#000000', bg = '#c586c0', gui = 'bold' },
        b = { fg = '#d4d4d4', bg = '#252526' },
        c = { fg = '#808080', bg = '#1e1e1e' },
      },
      replace = {
        a = { fg = '#000000', bg = '#d16969', gui = 'bold' },
        b = { fg = '#d4d4d4', bg = '#252526' },
        c = { fg = '#808080', bg = '#1e1e1e' },
      },
      command = {
        a = { fg = '#000000', bg = '#dcdcaa', gui = 'bold' },
        b = { fg = '#d4d4d4', bg = '#252526' },
        c = { fg = '#808080', bg = '#1e1e1e' },
      },
      inactive = {
        a = { fg = '#808080', bg = '#1e1e1e' },
        b = { fg = '#808080', bg = '#1e1e1e' },
        c = { fg = '#808080', bg = '#1e1e1e' },
      },
    }
  end
end

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = get_lualine_theme(),
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 100,  -- Refresh more frequently to update error state
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = { 
      { 'filename', path = 1 }
    },
    lualine_x = {
      { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
      'encoding', 'fileformat', 'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
})

-- Auto-refresh lualine when diagnostics change
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function()
    require('lualine').setup({
      options = {
        icons_enabled = true,
        theme = get_lualine_theme(),
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 100,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = { 
          { 'filename', path = 1 }
        },
        lualine_x = {
          { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
          'encoding', 'fileformat', 'filetype'
        },
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    })
  end,
})