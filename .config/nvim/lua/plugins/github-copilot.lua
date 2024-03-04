return {
	{ "zbirenbaum/copilot.lua",
		cmd = "Copilot",
		keys = {{ "<leader>C", ":Copilot! toggle<CR>", silent = true }},
		opts = {
			panel = { enable = false },
			suggestion = { auto_trigger = true },
			-- Keep Copilot disabled by default
			filetypes = { ["*"] = false },
		} },
}
