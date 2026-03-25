vim.g.mapleader = " "

-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- Some users without xclip or wl-copy on Linux systems will expirience slowness on calling: dd, dw, x, etc (on MacOS automatically supported with 'pbcopy')
vim.opt.clipboard = 'unnamedplus'

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

  -- Treesitter config (Highlighting)
  { 
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "python", "javascript", "typescript", "tsx", "bash", "dockerfile", "yaml" },
      highlight = { enable = true },
    },
    config = function(_, opts)
      -- Використовуємо pcall, щоб Neovim не падав, якщо плагін ще не завантажився
      local status, ts = pcall(require, "nvim-treesitter.configs")
      if status then
        ts.setup(opts)
      else
        -- У нових версіях Treesitter може працювати автоматично через opts
        -- або потребує лише завантаження основного модуля
        require("nvim-treesitter").setup(opts)
      end
    end
  },

  -- Neo-tree
  { 
    "nvim-neo-tree/neo-tree.nvim", 
    branch = "v3.x", 
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- додано сюди для стабільності
      "MunifTanjim/nui.nvim",        -- ОБОВ'ЯЗКОВА залежність для neo-tree
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
      })
    end
  },
})

-- UI & Tooling Config
require('lualine').setup()
require("mason").setup()
require("mason-lspconfig").setup({
  -- Сервери для стеку
  ensure_installed = { "pyright", "ts_ls", "dockerls", "lua_ls" },
})

-- LSP Config
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Налаштування конкретних серверів
local servers = { "pyright", "ts_ls", "dockerls", "lua_ls" }

for _, lsp in ipairs(servers) do
  local opts = { 
    capabilities = capabilities,
    -- Автоматичний запуск (замiсть lspconfig.setup)
    autostart = true,
 }
  
  if lsp == "lua_ls" then
    opts.settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      }
    }
  end
  
  -- Замість require('lspconfig')[lsp].setup(opts)
  -- Використовуємо вбудований метод, щоб уникнути Deprecation Warning
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
-- Keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {}) -- Перейти до визначення
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})       -- Документація під курсором
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {}) -- Code Actions
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})      -- Перейменувати змінну
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = "Toggle Explorer" }) -- Відкрити/Закрити neotree

-- Дизайн
-- Options
vim.cmd.colorscheme("catppuccin")
vim.opt.number = true
vim.opt.relativenumber = true