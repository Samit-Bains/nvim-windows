local function on_attach(bufnr)
    local api = require("nvim-tree.api")

    api.config.mappings.default_on_attach(bufnr)

    local function opts(desc)
        return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
        }
    end

    vim.keymap.set("n", "<Tab>", function()
        api.node.open.no_window_picker(nil, { focus = true })
    end, opts("Open Without Preview"))

    vim.keymap.set("n", "<S-Tab>", function()
        api.node.open.preview_no_picker(nil, { focus = true })
    end, opts("Open Preview"))
end

require("nvim-tree").setup({
    on_attach = on_attach,
    view = {
        width = 35,
    },
    renderer = {
        group_empty = true,
        highlight_git = true,
        icons = {
            show = {
                git = true,
                folder = true,
                file = true,
            },
            glyphs = {
                default = "",
                symlink = "",
                git = {
                    unstaged = "",
                    staged = "✓",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "",
                    deleted = "",
                    ignored = "◌",
                },
                folder = {
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                },
            }
        }
    },
    actions = {
        open_file = {
            resize_window = true,
        }
    },
    filters = {
        dotfiles = false,
    },
    git = {
        enable = true,
        ignore = false, -- SET THIS TO FALSE to show files ignored by .gitignore (like .env)
    },
})

-- Set NvimTree background to grey
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "#1e1e1e", fg = "#d4d4d4" })
vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "#1e1e1e", fg = "#d4d4d4" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "#1e1e1e", fg = "#1e1e1e" })
vim.api.nvim_set_hl(0, "NvimTreeVertSplit", { bg = "#1e1e1e", fg = "#1e1e1e" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "#1e1e1e", fg = "#1e1e1e" })

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
