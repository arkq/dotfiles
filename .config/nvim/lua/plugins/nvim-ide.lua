local function gps()
	return require("nvim-gps").get_location()
end

local function gps_is_available()
	return require("nvim-gps").is_available()
end

return {

	-- IDE-like session manager
	{ "rmagatti/auto-session",
		opts = { lazy_support = true },
		init = function()
			-- Add option recommended by the health check
			vim.opt.sessionoptions = vim.opt.sessionoptions + "localoptions"
		end },

	{ "nvim-lualine/lualine.nvim",
		dependencies = {
			"AndreM222/copilot-lualine",
			"nvim-tree/nvim-web-devicons" },
		opts = {
			sections = {
				lualine_c = { "filename", { gps, cond = gps_is_available } },
				lualine_x = { "copilot", "encoding", "filetype" } },
			extensions = { "fugitive", "man", "nvim-tree", "quickfix" },
		} },

	-- Breadcrumbs based on treesitter
	{ "SmiteshP/nvim-gps",
		opts = { disable_icons = true } },

	{ "nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<F2>", ":NvimTreeToggle<CR>",
				silent = true, desc = "Toggle File Explorer" } },
		opts = {
			on_attach = function(buffer)
				local api = require("nvim-tree.api")
				api.config.mappings.default_on_attach(buffer)
				-- Use <space> to expand/collapse nodes
				vim.keymap.set("n", "<space>", api.node.open.preview, { buffer = buffer })
			end,
		} },

	{ "majutsushi/tagbar",
		keys = {
			{ "<F8>", ":TagbarToggle<CR>",
				silent = true, desc = "Toggle TAG Explorer" } } },

	-- Fuzzy file finder
	{ "cloudhead/neovim-fuzzy",
		keys = {
			{ "<C-p>", ":FuzzyOpen<CR>",
				silent = true, desc = "Open Fuzzy File Finder" } },
		init = function()
			vim.g.fuzzy_hidden = 1
		end },

	-- The quickfix window 2.0
	{ "kevinhwang91/nvim-bqf",
		opts = { preview = { winblend = 0 } } },

	-- Switch between source and header
	{ "derekwyatt/vim-fswitch",
		lazy = false, -- Something is not right when lazy-loaded...
		keys = {
			{ "<leader>h", ":FSHere<CR>",
				silent = true, desc = "Switch between source and header file" } } },

	-- Comment-out code like a champ
	{ "tpope/vim-commentary",
		keys = {
			{ "<C-_>", ":Commentary<CR>", mode = { "n", "v" },
				silent = true, desc = "Toggle a comment" } } },

	-- Prevent opening files in special windows
	{ "stevearc/stickybuf.nvim",
		opts = {} },

	-- Open URLs with favorite browser
	{ "tyru/open-browser.vim",
		keys = {
			{ "<leader>g", "<Plug>(openbrowser-smart-search)",
				silent = true, desc = "Open/search current token in a web browser" } } },

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
