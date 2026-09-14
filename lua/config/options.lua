local opt = vim.opt

-- Números
opt.number = true
opt.relativenumber = true

-- Indentação
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- Indentação inteligente
opt.autoindent = true
opt.smartindent = true

-- O Neovim/Vim usa cindent para C/C++ através do filetype
opt.cindent = true

-- Visual
opt.wrap = false
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"

-- Busca
opt.ignorecase = true
opt.smartcase = true

-- Clipboard
opt.clipboard = "unnamedplus"

-- Navegação
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Interface
opt.splitright = true
opt.splitbelow = true

-- Edição
opt.backspace = { "indent", "eol", "start" }
opt.mouse = "a"
opt.hidden = true

-- Performance / experiência
opt.updatetime = 250
opt.timeoutlen = 400

-- Undotree persistente
opt.undofile = true
opt.undolevels = 10000

-- Espaços invisíveis úteis
opt.list = true
opt.listchars = {
    tab = "→ ",
    trail = "·",
    nbsp = "␣",
}

-- Evita arquivos temporários desnecessários
opt.swapfile = false
opt.backup = false
opt.writebackup = false
