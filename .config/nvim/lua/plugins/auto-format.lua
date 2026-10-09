-- Check if a file exists in the launch directory
local function cwdexists(filename)
  return vim.uv.fs_stat(vim.uv.cwd() .. "/" .. filename) ~= nil
end

-- Get C/C++ formatter based on the current directory setup
local function cformatter()
  if cwdexists(".uncrustify") then return "uncrustify" end
  if cwdexists(".clang-format") then return "clang_format" end
end

-- Setup formatexpr (gq) provider
vim.o.formatexpr = "v:lua.myformatexpr()"
_G.myformatexpr = function()
	-- Use default line wrapping for git commits
	if vim.bo.filetype == "gitcommit" then return 1 end
	-- The formatexpr() function sets the default timeout by itself, so the
	-- default set in the opts is not used. Used default timeout is 500 ms
	-- which is not enough on slow machines.
	return require("conform").formatexpr({ timeout_ms = 5000 })
end

return {
	{ "hynek/vim-python-pep8-indent",
		ft = "python" },
	{ "stevearc/conform.nvim",
		cmd = { "ConformInfo" },
		keys = {
			{ "<leader>q", function()
					require("conform").format({ async = true })
				end, desc = "Format current buffer" } },
		opts = {
			default_format_opts = { lsp_format = "fallback" },
			formatters_by_ft = {
				c = { cformatter() },
				cpp = { cformatter() },
				go = { "goimports" },
				markdown = { "mdformat" },
				python = { "ruff_fix", "isort", "autopep8" },
				rust = { "rustfmt" },
				sh = { "shellcheck" },
			} } },
}
