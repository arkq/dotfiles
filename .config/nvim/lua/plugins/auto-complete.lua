return {
	{ "hrsh7th/cmp-nvim-lsp",
		lazy = true,
		opts = {} },
	{ "saadparwaiz1/cmp_luasnip",
		dependencies = { "L3MON4D3/LuaSnip" },
		lazy = true },
	{ "hrsh7th/nvim-cmp",
		event = { "InsertEnter" },
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			cmp.setup({
				sources = cmp.config.sources({
					{ name = 'nvim_lsp', group_index = 1 },
					{ name = 'luasnip', group_index = 2 },
					{ name = 'path', group_index = 5 },
					{ name = 'buffer', group_index = 10 },
				}),
				mapping = cmp.mapping.preset.insert({
					['<CR>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							if luasnip.expandable() then
								luasnip.expand()
							else
								cmp.confirm()
							end
						else
							fallback()
						end
					end),
					['<Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.locally_jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end
				},
				completion = {
					keyword_length = 2,
				},
				performance = {
					max_view_entries = 15,
				},
			})
		end },
}
