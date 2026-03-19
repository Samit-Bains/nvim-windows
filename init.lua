-- Editor settings for horizontal scrolling
vim.opt.wrap = false
vim.opt.sidescroll = 5
vim.opt.sidescrolloff = 5

-- Load the lazy.lua file directly (not as a module)
dofile(vim.fn.stdpath("config") .. "/config/lazy.lua")