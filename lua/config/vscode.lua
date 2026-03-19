-- ~/.config/nvim/lua/config/vscode.lua
-- Extra config when running inside VSCode / VSCodium

if not vim.g.vscode then return end

-- Keep redraws light
vim.o.lazyredraw = true
vim.o.termguicolors = true
vim.o.relativenumber = false
vim.o.number = true

-- Quick helpers
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- --- Bootstrap lazy.nvim (plugin manager) ---
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- --- Minimal Lazy.nvim setup ---
require("lazy").setup({
  spec = {
    "nvim-lua/plenary.nvim",
    "tpope/vim-surround",
    "tpope/vim-commentary",
    "windwp/nvim-autopairs",
    { "folke/tokyonight.nvim",           config = function() vim.cmd.colorscheme("tokyonight-night") end },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    "neovim/nvim-lspconfig",
  },
  performance = {
    rtp = {
      disabled_plugins = { "netrwPlugin", "gzip", "tarPlugin", "tohtml", "zipPlugin" },
    },
  },
  ui = {
    border = "none",
    icons = false,
    backdrop = 0,
  },
})

-- --- Disable Lazy UI popup completely ---
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    pcall(function()
      require("lazy.view").close()
    end)
  end,
})
