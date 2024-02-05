vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.textwidth = 98

vim.opt.title = true
vim.opt.mousemodel = "extend"
vim.opt.mousehide = false

-- Terminal enhancements
vim.opt.lazyredraw = true
vim.opt.termguicolors = true
vim.opt.ttyfast = true

-- Quick command line mode
vim.keymap.set({ "n", "v" }, ";", ":")

-- Make vertical diff by default
vim.opt.diffopt = vim.opt.diffopt + "vertical"

vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spellfile = os.getenv("HOME") .. "/.config/nvim/spell.add"
vim.keymap.set("n", "<F7>", ":setlocal spell! spell?<CR>")

vim.opt.hidden = true
vim.opt.number = true
vim.opt.modeline = true
vim.opt.mouse = "a"

-- Enhanced command-line
vim.opt.wildignorecase = true
vim.opt.wildmenu = true

-- Completion menu improvement
vim.opt.completeopt = "longest,menuone"

-- IO latency workaround
vim.opt.updatetime = 750
vim.opt.directory = "/tmp"

-- Smart-ass search mode
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Nice line wrapping
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Folding tweaks
vim.opt.foldlevel = 666
vim.keymap.set("n", "<space>", "za")

-- Splits tweaks
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Syntax tweaks
vim.g.c_space_errors = 1
vim.g.python_space_errors = 1
vim.g.python_highlight_all = 1
