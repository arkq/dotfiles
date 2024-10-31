return {
	-- Package manager for LSP servers, DAP servers, linters, and formatters
	{ "williamboman/mason.nvim",
		-- Set up plug-ins in defined order
		priority = 120,
		opts = {} },
	-- Automatically setup all language servers
	{ "williamboman/mason-lspconfig.nvim",
		priority = 110,
		opts = { handlers = {
			function (server)
				-- Advertise auto-completion capabilities to LSP
				local caps = require("cmp_nvim_lsp").default_capabilities()
				require("lspconfig")[server].setup({ capabilities = caps })
			end
		} } },
}
