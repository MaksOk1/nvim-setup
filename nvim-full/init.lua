vim.g.mapleader = " "

-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- UI
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x", dependencies = { "nvim-lua/plenary.nvim" } },

  -- LSP CORE
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
  },

  -- Autocompletion Engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Treesitter (Highlighting)
  { 
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "tsx", "bash", "dockerfile", "yaml" },
        highlight = { enable = true },
      })
    end
  },
})

-- Treesitter config
-- require('nvim-treesitter.configs').setup({
--   ensure_installed = { "lua", "python", "javascript", "typescript", "tsx", "bash", "dockerfile", "yaml" },
--   highlight = { enable = true },
-- })

require("neo-tree").setup({})
require('lualine').setup()
require("mason").setup()
require("mason-lspconfig").setup({
  -- Сервери для стеку
  ensure_installed = { "pyright", "ts_ls", "dockerls", "lua_ls" },
})

local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Налаштування конкретних серверів
local servers = { "pyright", "ts_ls", "dockerls", "lua_ls" }
local capabilities = require('cmp_nvim_lsp').default_capabilities()
for _, lsp in ipairs(servers) do
  local opts = { capabilities = capabilities }
  
  if lsp == "lua_ls" then
    opts.settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      }
    }
  end
  
  -- Замість require('lspconfig')[lsp].setup(opts)
  -- використовуємо вбудований vim.lsp.config
  vim.lsp.config(lsp, opts)
end

-- Completion Config (CMP)
local cmp = require("cmp")
cmp.setup({
  snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

-- Основні гарячі клавіші для LSP
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {}) -- Перейти до визначення
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})       -- Документація під курсором
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {}) -- Code Actions
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})      -- Перейменувати змінну
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = "Toggle Explorer" }) -- Відкрити/Закрити neotree

-- Дизайн
vim.cmd.colorscheme("catppuccin")
vim.opt.number = true
vim.opt.relativenumber = true