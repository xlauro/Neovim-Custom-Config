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

-- Área de transferência: colar sobre seleção visual sem sobrescrever o registrador com o texto apagado
map("x", "<leader>p", [["_dP]], { desc = "Colar mantendo clipboard" })

-- Visualizador de erros e mensagens internas do Neovim (:messages) em janela flutuante
local function show_neovim_messages()
    local output = vim.api.nvim_exec2("messages", { output = true }).output
    local lines = vim.split(output, "\n")
    if #lines > 0 and lines[#lines] == "" then
        table.remove(lines, #lines)
    end

    if #lines == 0 then
        vim.notify("Nenhum erro ou mensagem registrada no Neovim.", vim.log.levels.INFO, { title = "Neovim" })
        return
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].filetype = "messages"

    local width = math.min(110, math.floor(vim.o.columns * 0.85))
    local height = math.min(30, math.floor(vim.o.lines * 0.80))
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.max(width, 30),
        height = math.max(height, 5),
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " Erros e Mensagens do Neovim (:messages) [q para fechar] ",
        title_pos = "center",
    })

    -- Posiciona no final onde ficam os erros mais recentes
    pcall(vim.api.nvim_win_set_cursor, win, { #lines, 0 })

    local close_opts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set("n", "q", "<cmd>close<cr>", close_opts)
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", close_opts)
end

vim.api.nvim_create_user_command("Messages", show_neovim_messages, { desc = "Exibir erros e mensagens do Neovim em janela flutuante" })
map("n", "<leader>m", show_neovim_messages, { desc = "Ver erros/mensagens do Neovim (:messages)" })
map("n", "<leader>M", "<cmd>messages clear<cr><cmd>lua vim.notify('Mensagens do Neovim limpas!', vim.log.levels.INFO, { title = 'Neovim' })<cr>", { desc = "Limpar mensagens do Neovim" })
