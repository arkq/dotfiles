return {
	{ url = "https://git.sr.ht/~ackyshake/VimCompletesMe.vim" },
	-- Keyword completion system
	{ "Shougo/deoplete.nvim",
		init = function()
			vim.g["deoplete#enable_at_startup"] = 1
		end },
	{ "lighttiger2505/deoplete-vim-lsp" },
}
