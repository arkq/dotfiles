return {
	{ "ilyachur/cmake4vim", ft = "cmake" },
	{ "artoj/qmake-syntax-vim", ft = "qmake" },
	{ "fatih/vim-go", ft = "go",
		init = function()
			-- Perform auto-import and formatting on save
			vim.g.go_fmt_command = "goimports"
		end },
	{ "jeroenbourgois/vim-actionscript", ft = "actionscript" },
	{ "pangloss/vim-javascript", ft = "javascript",
		init = function()
			vim.g.javascript_plugin_jsdoc = 1
		end },
	{ "othree/xml.vim" },
}
