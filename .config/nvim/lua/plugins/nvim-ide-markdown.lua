return {
	{ "plasticboy/vim-markdown", ft = "markdown",
		init = function()
			vim.g.vim_markdown_strikethrough = 1
		end },
	{ "JamshedVesuna/vim-markdown-preview", ft = "markdown",
		init = function()
			vim.g.vim_markdown_preview_hotkey = "<leader>p"
			vim.g.vim_markdown_preview_github = 1
			vim.g.vim_markdown_preview_use_xdg_open = 1
		end },
}
