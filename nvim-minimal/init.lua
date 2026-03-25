-- nvim-light/init.lua
vim.g.mapleader = " "

-- Тільки необхідне
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.syntax = 'on'

-- Вбудована мережа (Netrw) замість плагінів дерева
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

-- Швидкий вихід
vim.keymap.set('n', '<leader>q', ':q<CR>')
vim.keymap.set('n', '<leader>w', ':w<CR>')

print("Light config loaded!")