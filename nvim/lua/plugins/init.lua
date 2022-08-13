local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  })
  print('Installing packer close and reopen Neovim...')
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the init.lua file (BUGGY)
-- vim.cmd([[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost init.lua source "afile" | PackerSync
--   augroup end
-- ]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require('packer.util').float({
        border = 'rounded',
      })
    end,
  },
})

-- use packer to load plugins
return packer.startup(function(use)
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- Improve startup times – needed to load first
  use('lewis6991/impatient.nvim')
  use('nathom/filetype.nvim')
  use('nvim-lua/plenary.nvim')
  use({
    'mhinz/vim-startify',
    event = 'BufEnter',
    -- config = "require('plugins.startify')",
  })

  -- theme
  use({
    'AhmedAbdulrahman/aylin.vim',
    branch = '0.5-nvim',
  })

  -- Treesitter
  use({
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'romgrk/nvim-treesitter-context',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    run = ':TSUpdate',
    config = "require('plugins.treesitter')",
  })
  use('p00f/nvim-ts-rainbow')
  use('windwp/nvim-ts-autotag')

  -- comments --
  use({ 'numToStr/Comment.nvim', config = "require('plugins.comment')" })
  use('JoosepAlviste/nvim-ts-context-commentstring')

  -- telescope
  use({
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
  })
  use({
    'cljoly/telescope-repo.nvim',
  })
  use({
    'nvim-lua/telescope.nvim',
    requires = {
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-lua/popup.nvim',
    },
    config = "require('plugins.telescope')",
  })

  -- cmp plugins
  use({
    'hrsh7th/nvim-cmp',
    config = "require('plugins.cmp')",
  }) -- The completion plugin
  use('hrsh7th/cmp-buffer') -- buffer completions
  use('hrsh7th/cmp-path') -- path completions
  use('saadparwaiz1/cmp_luasnip') -- snippet completions
  use('hrsh7th/cmp-nvim-lsp')
  use('hrsh7th/cmp-nvim-lua')

  use({
    'windwp/nvim-autopairs',
    config = "require('plugins.autopairs')",
  }) -- Autopairs, integrates with both cmp and treesitter

  -- snippets
  use('L3MON4D3/LuaSnip') --snippet engine
  use('rafamadriz/friendly-snippets') -- a bunch of snippets to use

  -- LSP
  use({
    'neovim/nvim-lspconfig',
    config = "require('plugins.lsp')",
  }) -- enable LSP
  use('williamboman/nvim-lsp-installer') -- simple to use language server installer
  use('jose-elias-alvarez/null-ls.nvim') -- for formatters and linters
  use('jose-elias-alvarez/nvim-lsp-ts-utils')

  -- file tree
  use('kyazdani42/nvim-web-devicons')
  use({
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
    tag = 'nightly', -- optional, updated every week. (see issue #1193)
    config = "require('plugins.nvim-tree')",
  })

  use('norcalli/nvim-colorizer.lua') -- fast hex color previewer
  use({
    'mg979/vim-visual-multi',
    branch = 'master',
    config = "require('plugins.vim-visual-multi')",
  }) -- mutliple cursors
  use({
    'mhartington/formatter.nvim',
    config = "require('plugins.formatter')",
  }) -- file formatter

  -- easy surround strings with symbols
  use({
    'kylechui/nvim-surround',
    config = "require('nvim-surround').setup()",
  })

  -- Git
  use({ 'lewis6991/gitsigns.nvim', config = "require('plugins.gitsigns')" })
  use({ 'tpope/vim-fugitive' })
  use({
    'sindrets/diffview.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = "require('plugins.diffview')",
  })

  -- bufferline
  use({
    'akinsho/bufferline.nvim',
    tag = 'v2.*',
    requires = 'kyazdani42/nvim-web-devicons',
    config = "require('plugins.bufferline')",
  })
  use('moll/vim-bbye')

  -- useful toolbar
  use({
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = "require('plugins.lualine')",
  })

  -- terminal
  use({
    'akinsho/toggleterm.nvim',
    config = "require('plugins.toggleterm')",
  })

  -- shows the context of the currently visible buffer contents
  -- use('wellle/context.vim') -- disabled due to not being useful & conflicting mappings

  -- easy project managements
  use({ 'ahmedkhalf/project.nvim', config = "require('plugins.project_nvim')" })

  -- minimap
  use({ 'wfxr/minimap.vim', config = "require('plugins.minimap')" })

  -- custom keymappings docs
  use({ 'folke/which-key.nvim', config = "require('plugins.whichkey')" })

  -- changes the working directory to the project root when you open a file or directory
  use({ 'airblade/vim-rooter', config = "require('plugins.vim-rooter')" })
end)
