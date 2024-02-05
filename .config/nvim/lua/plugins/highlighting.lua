return {
	-- Whitespace highlighting
	{ "ntpeters/vim-better-whitespace" },
	-- Highlight word under cursor
	{ "RRethy/vim-illuminate",
		config = function() require("illuminate").configure({
			delay = 750,
			filetypes_denylist = { "NvimTree" },
		}) end },
}
