return {
	{ "windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()

			local pairs = require("nvim-autopairs")
			local Rule = require("nvim-autopairs.rule")
			local cond = require("nvim-autopairs.conds")

			pairs.setup({})

			-- Duplicate insertion with surrounding check
			local function rule_duplicate(a1, ins, a2, lang)
				pairs.add_rule(
					Rule(ins, ins, lang)
						:with_pair(function(opts)
							return a1..a2 == opts.line:sub(opts.col - #a1, opts.col + #a2 - 1)
						end)
						:with_move(cond.none())
						:with_cr(cond.none())
						:with_del(function(opts)
							local col = vim.api.nvim_win_get_cursor(0)[2]
							return a1..ins..ins..a2 == opts.line:sub(col - #a1 - #ins + 1, col + #ins + #a2)
						end)
				)
			end

			rule_duplicate('(', ' ', ')')
			rule_duplicate('[', ' ', ']')
			rule_duplicate('{', ' ', '}')

		end },
	{ "tpope/vim-surround" },
	{ "vim-scripts/matchit.zip" },
}
