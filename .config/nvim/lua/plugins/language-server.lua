return {
	-- Package manager for LSP servers, DAP servers, linters, and formatters
	{ "williamboman/mason.nvim",
		-- Set up plug-ins in defined order
		priority = 120,
		opts = {} },
	{ "williamboman/mason-lspconfig.nvim",
		priority = 110,
		opts = {} },
	{ "neovim/nvim-lspconfig",
		config = function()
			local lsp = require("lspconfig")
			-- Bash
			lsp.bashls.setup({})
			-- C/C++
			lsp.clangd.setup({})
			-- Lua
			lsp.lua_ls.setup({})
			-- Markdown
			lsp.marksman.setup({})
			-- Python
			lsp.pylsp.setup({})
		end },
}
