local actions = require("telescope.actions")

local function get_find_command()
  local fd = vim.fn.exepath("fd")
  if fd ~= "" then
    return {
      fd,
      "--type", "f",
      "--strip-cwd-prefix",
      "--hidden",
      "--no-ignore",
      "--exclude", ".git",
      "--exclude", "node_modules",
    }
  end

  local fdfind = vim.fn.exepath("fdfind")
  if fdfind ~= "" then
    return {
      fdfind,
      "--type", "f",
      "--strip-cwd-prefix",
      "--hidden",
      "--no-ignore",
      "--exclude", ".git",
      "--exclude", "node_modules",
    }
  end

  local rg = vim.fn.exepath("rg")
  if rg ~= "" then
    return {
      rg,
      "--files",
      "--hidden",
      "--no-ignore",
      "--glob", "!.git",
      "--glob", "!node_modules",
    }
  end

  return nil
end

require("telescope").setup({
  defaults = {
    prompt_prefix = "🔍 ",
    selection_caret = " ",
    path_display = { "truncate" },
    sorting_strategy = "ascending",
    file_ignore_patterns = { "node_modules", ".git" },
    layout_strategy = "horizontal",
    layout_config = {
      preview_width = 0.55,
    },
    mappings = {
      i = {
        ["<Tab>"] = actions.move_selection_next,
        ["<S-Tab>"] = actions.move_selection_previous,
        ["<C-Space>"] = actions.toggle_selection,
      },
      n = {
        ["<Tab>"] = actions.move_selection_next,
        ["<S-Tab>"] = actions.move_selection_previous,
        ["<Space>"] = actions.toggle_selection,
      },
    },
  },
  pickers = {
    find_files = {
      find_command = get_find_command(),
    },
    live_grep = {
      additional_args = function()
        return { "--hidden", "--no-ignore" }
      end
    },
  }
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
