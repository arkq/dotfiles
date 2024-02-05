return {
	{ "github/copilot.vim",
		keys = {{ "<leader>C", ":let b:copilot_enabled = !b:copilot_enabled<CR>", silent = true }},
		init = function()
			-- Keep Copilot disabled by default
			vim.b.copilot_enabled = 0
		end },
}
