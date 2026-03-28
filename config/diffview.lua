local actions = require("diffview.actions")

local function shared_panel_keymaps()
  return {
    { "n", "<leader><Tab>", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
    { "n", "<leader>tab", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
    { "n", "<leader>e", false },
    { "n", "<leader>b", false },
    { "n", "<leader>ge", actions.focus_files, { desc = "Focus Diffview files" } },
    { "n", "<leader>gb", actions.toggle_files, { desc = "Toggle Diffview files" } },
  }
end

local function merge_keymaps()
  return {
    { "n", "<leader>co", false },
    { "n", "<leader>ct", false },
    { "n", "<leader>cb", false },
    { "n", "<leader>ca", false },
    { "n", "<leader>cO", false },
    { "n", "<leader>cT", false },
    { "n", "<leader>cB", false },
    { "n", "<leader>cA", false },
    { "n", "<leader>mo", actions.conflict_choose("ours"), { desc = "Choose OURS conflict" } },
    { "n", "<leader>mt", actions.conflict_choose("theirs"), { desc = "Choose THEIRS conflict" } },
    { "n", "<leader>mb", actions.conflict_choose("base"), { desc = "Choose BASE conflict" } },
    { "n", "<leader>ma", actions.conflict_choose("all"), { desc = "Choose ALL conflict versions" } },
    { "n", "<leader>mO", actions.conflict_choose_all("ours"), { desc = "Choose OURS conflicts for file" } },
    { "n", "<leader>mT", actions.conflict_choose_all("theirs"), { desc = "Choose THEIRS conflicts for file" } },
    { "n", "<leader>mB", actions.conflict_choose_all("base"), { desc = "Choose BASE conflicts for file" } },
    { "n", "<leader>mA", actions.conflict_choose_all("all"), { desc = "Choose ALL conflicts for file" } },
  }
end

local view_keymaps = shared_panel_keymaps()
vim.list_extend(view_keymaps, merge_keymaps())

local file_panel_keymaps = shared_panel_keymaps()
vim.list_extend(file_panel_keymaps, merge_keymaps())

require("diffview").setup({
  enhanced_diff_hl = true,
  view = {
    default = {
      layout = "diff2_horizontal",
    },
    file_history = {
      layout = "diff2_horizontal",
    },
  },
  file_panel = {
    listing_style = "tree",
    tree_options = {
      flatten_dirs = true,
      folder_statuses = "only_folded",
    },
    win_config = {
      position = "left",
      width = 35,
    },
  },
  keymaps = {
    view = view_keymaps,
    file_panel = file_panel_keymaps,
    file_history_panel = shared_panel_keymaps(),
  },
})
