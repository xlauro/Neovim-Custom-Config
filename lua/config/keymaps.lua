-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set

-- Salva com Ctrl+S em qualquer modo e volta para o Normal Mode
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Salvar arquivo" })

-- Navegação direta entre splits/janelas (funciona com Neo-tree e Terminal)
map("n", "<C-h>", "<C-w>h", { desc = "Foco na janela à esquerda (Tree)" })
map("n", "<C-j>", "<C-w>j", { desc = "Foco na janela abaixo" })
map("n", "<C-k>", "<C-w>k", { desc = "Foco na janela acima" })
map("n", "<C-l>", "<C-w>l", { desc = "Foco na janela à direita (Código)" })

-- Focar diretamente na árvore de arquivos sem fechar
map("n", "<leader>o", "<cmd>Neotree focus<cr>", { desc = "Focar na árvore de arquivos" })

-- Redimensionar janelas ativas com Alt + Setas
map("n", "<A-Up>", "<cmd>resize +2<cr>", { desc = "Aumentar altura da janela" })
map("n", "<A-Down>", "<cmd>resize -2<cr>", { desc = "Diminuir altura da janela" })
map("n", "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Diminuir largura da janela" })
map("n", "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Aumentar largura da janela" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Limpar realce da busca" })
