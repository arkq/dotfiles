return {
	{ "hrsh7th/cmp-nvim-lsp",
		opts = {} },
	{ "hrsh7th/nvim-cmp",
		event = { "InsertEnter" },
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"quangnguyen30192/cmp-nvim-ultisnips",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				sources = cmp.config.sources({
					{ name = 'nvim_lsp', group_index = 1 },
					{ name = 'ultisnips', group_index = 5 },
					{ name = 'path', group_index = 5 },
					{ name = 'buffer', group_index = 10 },
				}),
				mapping = cmp.mapping.preset.insert({
					['<Tab>'] = cmp.mapping.select_next_item(),
					['<S-Tab>'] = cmp.mapping.select_prev_item(),
					['<CR>'] = cmp.mapping.confirm(),
				}),
				completion = {
					keyword_length = 2,
				},
				performance = {
					max_view_entries = 15,
				},
			})
		end },
}
