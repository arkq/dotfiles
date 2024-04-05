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
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local lsp = require("lspconfig")
			local caps = require("cmp_nvim_lsp").default_capabilities()
			-- Bash
			lsp.bashls.setup({ capabilities = caps })
			-- C/C++
			lsp.clangd.setup({ capabilities = caps })
			-- Lua
			lsp.lua_ls.setup({ capabilities = caps })
			-- Markdown
			lsp.marksman.setup({ capabilities = caps })
			-- Python
			lsp.pylsp.setup({ capabilities = caps })
		end },
}
