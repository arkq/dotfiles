return {
	{ "tpope/vim-fugitive",
		lazy = false,
		keys = {
			{ "<F4>", ":Git blame<CR>",
				silent = true, desc = "Toggle git blame" },
			-- Search current word in git repository
			{ "<leader>f", ":Ggrep! -q <cword><CR>",
				silent = true, desc = "Search current word in git" },
		} },
	-- Show annotations on the sign column
	{ "lewis6991/gitsigns.nvim",
		opts = {} },
	-- Search for pattern globally
	{ "jremmen/vim-ripgrep",
		-- Search current word in subdirectories
		keys = {
			{ "<leader>F", ":Rg <cword><CR>",
				silent = true, desc = "Search current word in subdirs" },
		} },
}
