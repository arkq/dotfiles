return {

	{ "nvim-treesitter/nvim-treesitter",
		-- This plug-in does not support lazy-loading.
		lazy = false,
		build = ":TSUpdate",
		config = function ()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				ensure_installed = { "c", "cpp", "lua", "python" },
				highlight = {
					enable = true,
					-- TS does not highlight title length correctly.
					disable = { "gitcommit" } },
			})
		end,
		init = function()
			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			-- Disable folding at startup.
			vim.opt.foldenable = false
		end },

	-- Highlight trailing whitespaces.
	{ "ntpeters/vim-better-whitespace" },

	-- Show whitespaces in visual mode.
	{ "mcauley-penney/visual-whitespace.nvim" },

	-- Highlight word under cursor.
	{ "RRethy/vim-illuminate",
		config = function() require("illuminate").configure({
			providers = { 'regex' },
			filetypes_denylist = { "NvimTree" },
			delay = 750,
		}) end },

}
