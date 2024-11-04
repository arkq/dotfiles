return {
	-- Run code in a REPL-like way
	{ "benlubas/molten-nvim",
		build = ":UpdateRemotePlugins",
		keys = {
			{ "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = { "v" },
				silent = true, desc = "REPL: Evaluate visual selection" },
			{ "<leader>rl", ":MoltenEvaluateLine<CR>",
				silent = true, desc = "REPL: Evaluate line" },
			{ "<leader>rr", ":MoltenReevaluateCell<CR>",
				silent = true, desc = "REPL: Re-evaluate cell" },
			{ "<leader>rd", ":MoltenDelete<CR>",
				silent = true, desc = "REPL: Delete cell" },
			{ "<leader>rc", ":MoltenInterrupt<CR>",
				silent = true, desc = "REPL: Interrupt evaluation" },
			{ "<leader>oh", ":MoltenHideOutput<CR>",
				silent = true, desc = "REPL: Hide output" },
			{ "<leader>os", ":noautocmd MoltenEnterOutput<CR>",
				silent = true, desc = "REPL: Enter/show output" },
		} },
}
