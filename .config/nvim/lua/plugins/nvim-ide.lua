local function gps()
	return require("nvim-gps").get_location()
end

local function gps_is_available()
	return require("nvim-gps").is_available()
end

return {

	{ "nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			sections = {
				lualine_c = { "filename", { gps, cond = gps_is_available } },
				lualine_x = { "encoding", "filetype" } },
			extensions = { "fugitive", "nvim-tree", "quickfix" },
		} },

	-- Breadcrumbs based on treesitter
	{ "SmiteshP/nvim-gps",
		opts = { disable_icons = true } },

	{ "nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {{ "<F2>", ":NvimTreeToggle<CR>", silent = true }},
		opts = {
			on_attach = function(buffer)
				local api = require("nvim-tree.api")
				api.config.mappings.default_on_attach(buffer)
				-- Use <space> to expand/collapse nodes
				vim.keymap.set("n", "<space>", api.node.open.preview, { buffer = buffer })
			end,
		} },

	{ "majutsushi/tagbar",
		keys = {{ "<F8>", ":TagbarToggle<CR>", silent = true }} },

	-- Fuzzy file finder
	{ "cloudhead/neovim-fuzzy",
		keys = {{ "<C-p>", ":FuzzyOpen<CR>", silent = true }},
		init = function()
			vim.g.fuzzy_hidden = 1
		end },

	-- The quickfix window 2.0
	{ "kevinhwang91/nvim-bqf",
		opts = { preview = { winblend = 0 } } },

	-- Switch between source and header
	{ "derekwyatt/vim-fswitch",
		lazy = false, -- Something is not right when lazy-loaded...
		keys = {{ "<leader>h", ":FSHere<CR>", silent = true }} },

	-- Comment-out code like a champ
	{ "tpope/vim-commentary",
		keys = {{ "<C-_>", ":Commentary<CR>", mode = { "n", "v" }, silent = true }} },

	-- Open URLs with favorite browser
	{ "tyru/open-browser.vim",
		keys = {{ "<leader>g", "<Plug>(openbrowser-smart-search)", silent = true }} },

}
