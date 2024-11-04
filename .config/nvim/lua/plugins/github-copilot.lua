return {
	{ "zbirenbaum/copilot.lua",
		cmd = "Copilot",
		keys = {
			{ "<leader>C", ":Copilot! toggle<CR>",
				silent = true, desc = "Toogle GitHub Copilot" } },
		opts = {
			panel = { enable = false },
			suggestion = { auto_trigger = true },
			-- Keep Copilot disabled by default
			filetypes = { ["*"] = false },
		} },
}
