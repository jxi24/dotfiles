-- Only required if you have packer in your `opt` pack
local packer_exists = pcall(vim.cmd, [[packadd packer.nvim]])

if not packer_exists then
    if vim.fn.input("Download Packer? (y for yes)") ~= "y" then
        return
    end

    local directory = string.format(
        '%s/site/pack/packer/opt/',
        vim.fn.stdpath('data')
    )

    vim.fn.mkdir(directory, 'p')

    local out = vim.fn.system(string.format(
        'git clone %s %s',
        'https://github.com/wbthomason/packer.nvim',
        directory .. '/packer.nvim'
    ))

    print(out)
    print("Downloading packer.nvim...")

    return
end

return require('packer').startup(function()
    -- Packer can manage itself as an optional plugin
    use {'wbthomason/packer.nvim', opt = true}

    -- Load colorschemes
    use 'tjdevries/colorbuddy.vim'
    use 'tjdevries/gruvbuddy.nvim'
    use 'Th3Whit3Wolf/spacebuddy'
    use 'Th3Whit3Wolf/onebuddy'
    use 'norcalli/nvim-base16.lua'
    use 'joshdick/onedark.vim'
    use 'tyrannicaltoucan/vim-deep-space'
    use { 'dracula/vim', as='dracula' }
    use 'sainnhe/edge'
    use 'sainnhe/sonokai'
    use 'bluz71/vim-nightfly-guicolors'
    use 'mhartington/oceanic-next'
    use 'glepnir/zephyr-nvim'

    -- telescope
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-fzy-native.nvim'
    use 'nvim-telescope/telescope-fzf-writer.nvim'
    use 'nvim-telescope/telescope-github.nvim'
    use 'nvim-telescope/telescope-packer.nvim'
    use 'nvim-telescope/telescope-dap.nvim'
    use 'nvim-telescope/telescope-symbols.nvim'

    -- tmux integration for vim
    use 'benmills/vimux'
    use 'christoomey/vim-tmux-navigator'

    -- status line
    use 'tjdevries/express_line.nvim'
    -- use 'liuchengxu/eleline.vim'

    -- text manipulation
    use 'godlygeek/tabular'
    use 'tpope/vim-abolish'
    use 'tpope/vim-commentary'
    use 'tpope/vim-unimpaired'
    use 'tpope/vim-surround'
    use 'tpope/vim-repeat'
    use 'tpope/vim-endwise'

    -- Startify
    use 'mhinz/vim-startify'

    -- context-aware pasting
    use 'sickill/vim-pasta'

    -- devicons
    -- use 'ryanoasis/vim-devicons'

    use 'kyazdani42/nvim-web-devicons'
    -- use 'kyazdani42/nvim-tree.lua'

    -- Better increment/decrement
    use 'monaqa/dial.nvim'

    -- Focus
    use 'junegunn/goyo.vim'
    use 'junegunn/limelight.vim'

    -- Lua
    use 'euclidianAce/BetterLua.vim'
    use 'tjdevries/nlua.nvim'

    -- C++
    use 'rhysd/vim-clang-format'

    -- latex
    use {'lervag/vimtex', config = [[require('config.vimtex')]]}

    -- neovim lsp
    use 'neovim/nvim-lspconfig'
    use 'nvim-lua/lsp-status.nvim'
    use 'nvim-lua/completion-nvim'
    use {'nvim-treesitter/completion-treesitter',
         run = function() vim.cmd [[TSUpdate]] end
    }
    use 'glepnir/lspsaga.nvim'

    -- snippets
    use 'norcalli/snippets.nvim'
    use 'norcalli/nvim-terminal.lua'

    -- debugger
    use 'mfussenegger/nvim-dap'
    use 'mfussenegger/nvim-dap-python'
    use {
        'theHamsta/nvim-dap-virtual-text',
        run = function()
            vim.g.dap_virtual_text = true
        end
    }

    -- Cool tags based viewer
    --   :Vista  <-- Opens up a really cool sidebar with info about file.
    use 'liuchengxu/vista.vim'

    -- Treesitter
    use 'nvim-treesitter/nvim-treesitter'
    use 'nvim-treesitter/nvim-treesitter-refactor'

    -- GIT
    use 'lambdalisue/gina.vim'
    use 'kdheepak/lazygit.nvim'
    use 'rhysd/committia.vim'
    use 'rhysd/git-messenger.vim'
    use 'mhinz/vim-signify'
    use 'pwntester/octo.nvim'

    -- FZF
    use {'junegunn/fzf', run = './install --all' }
    use {'junegunn/fzf.vim'}

    -- Browser
    use 'tyru/open-browser.vim'

    -- Productivity
    use 'vimwiki/vimwiki'
    use 'tools-life/taskwiki'

    -- Which-key
    use { 'folke/which-key.nvim',
          config = function()
              require('which-key').setup {
              }
          end
      }
end)

