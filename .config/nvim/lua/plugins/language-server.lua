local lspsetup = function(server)
	local caps = require("cmp_nvim_lsp").default_capabilities()
	-- Advertise auto-completion capabilities to LSP server.
	vim.lsp.config(server, { capabilities = caps })
	-- Enable LSP server.
	vim.lsp.enable(server)
end

return {
	{ "neovim/nvim-lspconfig",
		config = function()

			-- Enable common LSP servers. It is safe to enable servers which
			-- might not be available on the host. In such case LSP will not
			-- be enabled, that's all.
			lspsetup('clangd')
			lspsetup('ruff')

			-- Show LSP diagnostics in the quickfix window.
			vim.api.nvim_create_autocmd("DiagnosticChanged", {
				callback = function()
					vim.diagnostic.setqflist({ open = false })
				end,
			})

		end },
	-- Package manager for LSP servers, DAP servers and more.
	{ "williamboman/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig" },
		opts = { handlers = { lspsetup } } },
	-- Allow to use non-LSP tools as LSP providers.
	{ "nvimtools/none-ls.nvim",
		dependencies = {
			"gbprod/none-ls-shellcheck.nvim",
			"nvim-lua/plenary.nvim" },
		opts = function()
			return {
				sources = {
					require("none-ls-shellcheck.diagnostics"),
				}
			}
		end },
}
