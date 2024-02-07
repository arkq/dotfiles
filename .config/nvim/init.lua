-- Bootstrap lazy.nvim - modern plug-in manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Change the leader (global option) from <backslash> to <comma> before
-- loading the plug-in manager. Otherwise, it will complain...
vim.g.mapleader = ","

-- Setup and load plug-ins
require("lazy").setup({
	change_detection = { enabled = false },
	spec = {
		-- Defaults everyone can agree on
		{ "tpope/vim-sensible", priority = 1000 },
		-- Use color capabilities of modern terminals
		{ "tanvirtin/monokai.nvim", priority = 1100,
			opts = {} },
		-- Load plug-ins from the lua/plugins directory
		{ import = "plugins" },
	},
})

require("options")
require("keymaps")
