-- Clear existing highlights to prevent conflicts
local function set_ts_highlight()
    -- Regular comments (VS Code default)
    vim.api.nvim_set_hl(0, "@comment", { fg = "#6A9955" })
    
    -- Better Comments style highlights
    vim.api.nvim_set_hl(0, "@comment.alert", { fg = "#FF2D00" })      -- Red for //!
    vim.api.nvim_set_hl(0, "@comment.highlight", { fg = "#98C379" })  -- Light green for //*
    vim.api.nvim_set_hl(0, "@comment.todo", { fg = "#FF8C00" })       -- Orange for //TODO
end

-- Set up initial highlights
set_ts_highlight()

-- Ensure highlights persist after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = set_ts_highlight
})

local languages = {
    "lua",
    "typescript",
    "javascript",
    "tsx",
    "css",
    "json",
    "html",
    "markdown",
    "jsdoc",
    "go",
}

local supported_filetypes = {
    lua = true,
    typescript = true,
    javascript = true,
    typescriptreact = true,
    javascriptreact = true,
    css = true,
    json = true,
    html = true,
    markdown = true,
    go = true,
}

pcall(vim.treesitter.language.register, "tsx", "typescriptreact")
pcall(vim.treesitter.language.register, "tsx", "javascriptreact")

local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
    return
end

local ok_parsers, ts_parsers = pcall(require, "nvim-treesitter.parsers")
if ok_parsers then
    ts_parsers.ft_to_lang = ts_parsers.ft_to_lang or function(filetype)
        if vim.treesitter.language and vim.treesitter.language.get_lang then
            return vim.treesitter.language.get_lang(filetype) or filetype
        end
        return filetype
    end

    ts_parsers.get_parser = ts_parsers.get_parser or function(bufnr, lang)
        return vim.treesitter.get_parser(bufnr, lang)
    end
end

local ts_compat_configs = {
    get_module = function(module)
        if module == "highlight" then
            return {
                enable = true,
                additional_vim_regex_highlighting = false,
            }
        end

        return {
            enable = false,
            additional_vim_regex_highlighting = false,
        }
    end,
    is_enabled = function(module, lang, bufnr)
        if module ~= "highlight" then
            return false
        end

        local ok_parser = pcall(vim.treesitter.get_parser, bufnr, lang)
        return ok_parser
    end,
}

package.preload["nvim-treesitter.configs"] = package.preload["nvim-treesitter.configs"] or function()
    return ts_compat_configs
end
package.loaded["nvim-treesitter.configs"] = ts_compat_configs

treesitter.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})

local function enable_treesitter(bufnr)
    local filetype = vim.bo[bufnr].filetype
    if not supported_filetypes[filetype] then
        return
    end

    local started = pcall(vim.treesitter.start, bufnr)
    if started then
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = vim.tbl_keys(supported_filetypes),
    callback = function(args)
        enable_treesitter(args.buf)
    end,
})

if vim.bo.filetype ~= "" then
    enable_treesitter(0)
end

local installed = treesitter.get_installed("parsers")
local missing = {}

for _, language in ipairs(languages) do
    if not vim.tbl_contains(installed, language) then
        table.insert(missing, language)
    end
end

if #missing > 0 then
    treesitter.install(missing)
end
