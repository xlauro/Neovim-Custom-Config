-- ~/.config/nvim/lua/plugins/dap.lua
return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
            "williamboman/mason.nvim",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Suprime o falso-positivo do LuaLS para a tabela parcial de configuração
            ---@diagnostic disable-next-line: missing-fields
            dapui.setup({
                icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
                layouts = {
                    {
                        elements = {
                            { id = "scopes",      size = 0.40 },
                            { id = "breakpoints", size = 0.20 },
                            { id = "stacks",      size = 0.20 },
                            { id = "watches",     size = 0.20 },
                        },
                        size = 40,
                        position = "left",
                    },
                    {
                        elements = {
                            { id = "repl",    size = 0.60 },
                            { id = "console", size = 0.40 },
                        },
                        size = 10,
                        position = "bottom",
                    },
                },
            })

            require("nvim-dap-virtual-text").setup({
                commented = true,
                highlight_changed_variables = true,
            })

            -- Localiza o binário do CodeLLDB instalado pelo Mason
            local mason_registry = require("mason-registry")
            local codelldb_path = ""

            if mason_registry.is_installed("codelldb") then
                local codelldb = mason_registry.get_package("codelldb")
                local extension_path = codelldb:get_install_path() .. "/extension/"
                codelldb_path = extension_path .. "adapter/codelldb"
            else
                codelldb_path = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
            end

            -- Adapter nativo TCP/Server (estável, sem conflito de pipes)
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = codelldb_path,
                    args = { "--port", "${port}" },
                },
            }

            -- Abre a UI automaticamente quando o processo de depuração é iniciado
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
            -- Configuração unificada para C, C++, Rust e Zig
            local default_config = {
                {
                    name = "Depurar Executável",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        local current_file = vim.fn.expand("%:t:r")
                        local default_bin = vim.fn.getcwd() .. "/" .. current_file
                        return vim.fn.input("Caminho do binário compilado: ", default_bin, "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    runInTerminal = false,
                    console = "integratedTerminal",
                },
            }

            dap.configurations.c = default_config
            dap.configurations.cpp = default_config
            dap.configurations.rust = default_config
            dap.configurations.zig = default_config

            -- Ícones de breakpoints na coluna de sinais (gutter)
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition",
                { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped",
                { text = "▶", texthl = "DiagnosticOk", linehl = "CursorLine", numhl = "CursorLine" })

            -- Atalhos sob o grupo <leader>d
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Alternar Breakpoint" })
            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Iniciar / Continuar Debug" })
            vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Passar linha (Step Over)" })
            vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Entrar na função (Step Into)" })
            vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Sair da função (Step Out)" })
            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Alternar painel da UI" })

            -- Encerramento e restauração limpa da tela
            vim.keymap.set("n", "<leader>dt", function()
                dap.terminate()
                dapui.close()
                vim.cmd("silent! bd! [dap-terminal]")
            end, { desc = "Encerrar Debug e Fechar Painéis" })
        end,
    },
}
