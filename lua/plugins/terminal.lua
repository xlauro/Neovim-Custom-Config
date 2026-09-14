-- ~/.config/nvim/lua/plugins/terminal.lua
return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            local toggleterm = require("toggleterm")

            -- Calcula 35% da altura da tela para o terminal horizontal
            local function get_horizontal_size()
                return math.floor(vim.o.lines * 0.35)
            end

            toggleterm.setup({
                open_mapping = nil,
                size = function(term)
                    if term.direction == "horizontal" then
                        return get_horizontal_size()
                    elseif term.direction == "vertical" then
                        return math.floor(vim.o.columns * 0.4)
                    end
                end,
                hide_numbers = true,
                shade_terminals = true,
                start_in_insert = true,
                insert_mappings = false,
                terminal_mappings = false,
                persist_size = true,
                close_on_exit = false,
            })

            -- Atalhos específicos para o buffer do terminal
            vim.api.nvim_create_autocmd("TermOpen", {
                pattern = "term://*",
                callback = function(event)
                    local opts = { buffer = event.buf, silent = true }

                    -- Sair da inserção do terminal
                    vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], opts)

                    -- Fechar terminal
                    vim.keymap.set("t", "<C-q>", [[<C-\><C-n><cmd>close<CR>]], opts)
                    vim.keymap.set("n", "q", "<cmd>close<CR>", opts)

                    -- Navegação entre janelas a partir do terminal
                    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
                    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
                    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
                    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)

                    -- Redimensionamento direto de dentro do terminal com Alt + Setas
                    vim.keymap.set("t", "<A-Up>", [[<Cmd>resize +2<CR>]], opts)
                    vim.keymap.set("t", "<A-Down>", [[<Cmd>resize -2<CR>]], opts)
                    vim.keymap.set("t", "<A-Left>", [[<Cmd>vertical resize -2<CR>]], opts)
                    vim.keymap.set("t", "<A-Right>", [[<Cmd>vertical resize +2<CR>]], opts)
                end,
            })

            local function toggle_horizontal()
                vim.cmd(string.format("1ToggleTerm direction=horizontal size=%d", get_horizontal_size()))
            end

            local function toggle_vertical()
                vim.cmd("2ToggleTerm direction=vertical")
            end

            vim.keymap.set("n", "<leader>ft", toggle_horizontal, { desc = "Toggle Terminal Horizontal" })
            vim.keymap.set("n", "<leader>fT", toggle_vertical, { desc = "Toggle Terminal Vertical" })

            local function run_in_terminal(cmd)
                if not cmd or cmd == "" then return end
                vim.cmd("w")
                toggleterm.exec(cmd, 1, get_horizontal_size(), nil, "horizontal")
            end

            local function get_command(action)
                local ft = vim.bo.filetype
                local file = vim.fn.expand("%")
                local out = vim.fn.expand("%:r")

                local commands = {
                    rust = {
                        build = "cargo build",
                        run = "cargo run",
                    },
                    zig = {
                        build = vim.fn.filereadable("build.zig") == 1 and "zig build" or
                        string.format("zig build-exe -O Debug %s", file),
                        run = vim.fn.filereadable("build.zig") == 1 and "zig build run" or
                        string.format("zig run %s", file),
                    },
                    c = {
                        build = vim.fn.filereadable("Makefile") == 1 and "make" or
                        string.format("gcc -g -O0 -Wall %s -o %s", file, out),
                        run = vim.fn.filereadable("Makefile") == 1 and "make run" or
                        string.format("gcc -g -O0 -Wall %s -o %s && ./%s", file, out, out),
                    },
                    cpp = {
                        build = vim.fn.filereadable("Makefile") == 1 and "make" or
                        string.format("g++ -g -O0 -Wall -std=c++20 %s -o %s", file, out),
                        run = vim.fn.filereadable("Makefile") == 1 and "make run" or
                        string.format("g++ -g -O0 -Wall -std=c++20 %s -o %s && ./%s", file, out, out),
                    },
                }

                if commands[ft] and commands[ft][action] then
                    return commands[ft][action]
                end

                vim.notify("Nenhum comando de " .. action .. " configurado para " .. ft, vim.log.levels.WARN)
                return nil
            end

            vim.keymap.set("n", "<leader>cb", function() run_in_terminal(get_command("build")) end,
                { desc = "Compilar (Build)" })
            vim.keymap.set("n", "<leader>cx", function() run_in_terminal(get_command("run")) end,
                { desc = "Executar (Run)" })
        end,
    },
}
