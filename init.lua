-- ~/.config/nvim/init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")

-- Filetype detection + plugins + indentação específica da linguagem
vim.cmd("filetype plugin indent on")


require("config.lazy")
