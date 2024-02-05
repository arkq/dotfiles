return {
	{ "SirVer/ultisnips",
		init = function()
			-- Non-TAB based snippet expansion
			vim.g.UltiSnipsExpandTrigger = "<C-j>"
		end },
	{ "honza/vim-snippets" },
}
