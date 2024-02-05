-- Do not insert newline upon item selection in pop-up
vim.keymap.set("i", "<CR>", 'pumvisible() ? "\\<C-y>" : "\\<C-g>u\\<CR>"', { expr = true })
