-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.0',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

  -- use "olimorris/onedarkpro.nvim"
  use 'navarasu/onedark.nvim'
  use {
      'nvim-lualine/lualine.nvim',
      requires = { 'nvim-tree/nvim-web-devicons' }
  }
  use 'numToStr/Comment.nvim'
  use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
  use 'theprimeagen/harpoon'
  use 'mbbill/undotree'
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }

  use {
	  'VonHeikemen/lsp-zero.nvim',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }

  -- DAP
  use {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
      "jayp0521/mason-nvim-dap.nvim",
  }

  -- CMake
  -- use 'Civitasv/cmake-tools.nvim'

  -- OrgMode
  use { 'nvim-orgmode/orgmode' }

  -- Git
  use {
      'ldelossa/gh.nvim',
      requires = { { 'ldelossa/litee.nvim' } }
  }
  use {
      'lewis6991/gitsigns.nvim',
      -- tag = 'release', -- To use the latest release (do not use this if you run Neovim nightly or dev builds!)
  }

  -- tmux navigation
  use({ 'mrjones2014/smart-splits.nvim' })

  -- Lua
  use {
      "folke/which-key.nvim",
      config = function()
          require("which-key").setup {}
      end
  }

  -- trouble
  use {
      "folke/trouble.nvim",
      requires = "nvim-tree/nvim-web-devicons",
  }
  use {
      "folke/todo-comments.nvim",
      requires = "nvim-lua/plenary.nvim",
  }

  -- Neorg
  use {
      "nvim-neorg/neorg",
      requires = { "nvim-neorg/neorg-telescope" },
      run = ":Neorg sync-parsers",
  }

  use 'sidebar-nvim/sidebar.nvim'
  use 'lervag/vimtex'
  use({
      "folke/noice.nvim",
      requires = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
      },
  })

  use {
      "ThePrimeagen/refactoring.nvim",
      requires = {
          {"nvim-lua/plenary.nvim"},
          {"nvim-treesitter/nvim-treesitter"}
      }
  }

  use({
      "utilyre/barbecue.nvim",
      requires = {
          "neovim/nvim-lspconfig",
          "smiteshp/nvim-navic",
          "nvim-tree/nvim-web-devicons", -- optional dependency
      },
  })

  use {
      "danymat/neogen",
      requires = "nvim-treesitter/nvim-treesitter",
      -- Uncomment next line if you want to follow only stable versions
      -- tag = "*"
  }

  use {"akinsho/toggleterm.nvim", tag = '*'}

  use "fladson/vim-kitty"
  use "knubie/vim-kitty-navigator"
end)
