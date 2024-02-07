return {

	{ "nvim-treesitter/nvim-treesitter",
		tag = "v0.8.5.2",
		build = ":TSUpdate",
		config = function () require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "cpp", "lua", "python" },
			highlight = { enable = true },
		}) end,
		init = function()
			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			-- Disable folding at startup
			vim.opt.foldenable = false
		end },

	-- Whitespace highlighting
	{ "ntpeters/vim-better-whitespace" },

	-- Highlight word under cursor
	{ "RRethy/vim-illuminate",
		config = function() require("illuminate").configure({
			providers = { 'regex' },
			filetypes_denylist = { "NvimTree" },
			delay = 750,
		}) end },

}
