local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Basic UI options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Clipboard mappings (Ctrl+Shift+c/v)
-- Note: Terminal intercept might prevent these from working in some environments
vim.keymap.set('v', '<C-S-c>', '"+y')
vim.keymap.set('n', '<C-S-v>', '"+p')
vim.keymap.set('i', '<C-S-v>', '<C-r>+')

-- Disable arrow keys
local modes = { 'n', 'i', 'v' }
local arrows = { '<up>', '<down>', '<left>', '<right>' }
for _, mode in ipairs(modes) do
  for _, arrow in ipairs(arrows) do
    vim.keymap.set(mode, arrow, '<nop>')
  end
end

require("lazy").setup({
  spec = {
    -- Auto-close parentheses and quotes
    -- Removed 'event' so it loads immediately on startup
    {
      'windwp/nvim-autopairs',
      config = true
    },

    -- Fuzzy Finder (Telescope)
    {
      'nvim-telescope/telescope.nvim', tag = 'v0.2.1',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      },
      config = function()
        local builtin = require("telescope.builtin")
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<C-p>', builtin.find_files, {})
      end
    },

    -- Theme (Catppuccin)
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = false,
        })
        vim.cmd.colorscheme "catppuccin"
      end
    },

    -- Status Line (Lualine)
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        options = {
          theme = 'catppuccin',
          component_separators = '|',
          section_separators = '',
        },
      },
    },

    -- File Explorer (Nvim-Tree)
    {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("nvim-tree").setup {}
        vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
      end,
    },

    -- Syntax Highlighting (Treesitter)
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        -- Protected call to prevent crash if plugin isn't installed yet
        local status_ok, configs = pcall(require, "nvim-treesitter.configs")
        if not status_ok then
          return
        end

        configs.setup({
          ensure_installed = { "c++", "c", "lua", "vim", "vimdoc", "query", "javascript", "html", "python" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    }
  },
  checker = { enabled = true },
})
