return {
	{ "hynek/vim-python-pep8-indent", ft = "python" },
	{ "davidhalter/jedi-vim", ft = "python",
		init = function()
			vim.g["jedi#auto_vim_configuration"] = 0
			vim.g["jedi#completions_enabled"] = 0
			vim.g["jedi#show_call_signatures"] = 0
			vim.g["jedi#smart_auto_mappings"] = 0
			vim.cmd("autocmd FileType python setlocal omnifunc=jedi#completions")
		end },
	{ "zchee/deoplete-jedi", ft = "python" },
	{ "fisadev/vim-isort", ft = "python",
		keys = {{ "<C-i>", ":Isort<CR>", silent = true }} },
}
