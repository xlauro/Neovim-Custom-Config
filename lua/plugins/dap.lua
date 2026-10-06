-- ~/.config/nvim/lua/plugins/dap.lua
return {
    {
        "mfussenegger/nvim-dap",
        keys = {
            -- Atalhos padrão VS Code (F-keys)
            { "<F5>", desc = "Debug: Iniciar / Continuar" },
            { "<F9>", desc = "Debug: Alternar Breakpoint" },
            { "<F10>", desc = "Debug: Passar linha (Step Over)" },
            { "<F11>", desc = "Debug: Entrar na função (Step Into)" },
            { "<S-F11>", desc = "Debug: Sair da função (Step Out)" },
            { "<S-F5>", desc = "Debug: Encerrar Debug" },
            -- Atalhos sob <leader>d
            { "<leader>db", desc = "Alternar Breakpoint" },
            { "<leader>dB", desc = "Breakpoint condicional" },
            { "<leader>de", desc = "Avaliar expressão no debug", mode = { "n", "v" } },
            { "<leader>dc", desc = "Iniciar / Continuar Debug" },
            { "<leader>do", desc = "Passar linha (Step Over)" },
            { "<leader>di", desc = "Entrar na função (Step Into)" },
            { "<leader>dO", desc = "Sair da função (Step Out)" },
            { "<leader>du", desc = "Alternar painel da UI" },
            { "<leader>dt", desc = "Encerrar Debug e Fechar Painéis" },
            { "<leader>Gd", desc = "Go: Iniciar Debug (DAP)" },
        },
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

            -- 1. Adapter CodeLLDB (C, C++, Rust)
            local codelldb_path = vim.fn.exepath("codelldb")
            if codelldb_path == "" then
                codelldb_path = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
            end

            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = codelldb_path,
                    args = { "--port", "${port}" },
                },
            }

            -- 2. Adapter js-debug-adapter (TypeScript, JavaScript, Node.js, Bun)
            local js_debug_path = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter"
            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = js_debug_path,
                    args = { "${port}" },
                },
            }

            -- 3. Adapter Delve (Go)
            local dlv_path = vim.fn.exepath("dlv")
            if dlv_path == "" then
                dlv_path = vim.fn.stdpath("data") .. "/mason/bin/dlv"
            end
            dap.adapters.delve = function(callback, config)
                if config.request == "attach" and config.mode == "remote" then
                    local host = config.host or "127.0.0.1"
                    local port = config.port or "38697"
                    callback({
                        type = "server",
                        host = host,
                        port = port,
                    })
                    return
                end
                callback({
                    type = "server",
                    port = "${port}",
                    executable = {
                        command = dlv_path ~= "" and dlv_path or "dlv",
                        args = { "dap", "-l", "127.0.0.1:${port}" },
                    },
                })
            end

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

            -- Configurações para C, C++ e Rust
            local default_native_config = {
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

            dap.configurations.c = default_native_config
            dap.configurations.cpp = default_native_config
            dap.configurations.rust = {
                {
                    name = "Depurar Executável Rust (Cargo)",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        local cwd = vim.fn.getcwd()
                        local default_bin = cwd .. "/" .. vim.fn.expand("%:t:r")
                        if vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
                            for line in io.lines(cwd .. "/Cargo.toml") do
                                local name = line:match('^%s*name%s*=%s*"([^"]+)"')
                                if name then
                                    local cargo_bin = cwd .. "/target/debug/" .. name
                                    if vim.fn.filereadable(cargo_bin) == 1 or vim.fn.isdirectory(cwd .. "/target") == 1 then
                                        default_bin = cargo_bin
                                    end
                                    break
                                end
                            end
                        end
                        return vim.fn.input("Caminho do binário compilado: ", default_bin, "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    runInTerminal = false,
                    console = "integratedTerminal",
                },
            }

            -- Configurações para TypeScript, JavaScript e TSX
            local default_js_config = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Depurar com Node.js (arquivo atual)",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                    protocol = "inspector",
                    console = "integratedTerminal",
                },
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Depurar com Bun (arquivo atual)",
                    runtimeExecutable = "bun",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                    protocol = "inspector",
                    console = "integratedTerminal",
                },
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Depurar com TSX / ts-node (arquivo atual)",
                    runtimeExecutable = "npx",
                    runtimeArgs = { "tsx" },
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                    protocol = "inspector",
                    console = "integratedTerminal",
                },
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Anexar ao Processo (Attach)",
                    processId = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                },
            }

            for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
                dap.configurations[lang] = default_js_config
            end

            -- Configurações para Go
            dap.configurations.go = {
                {
                    type = "delve",
                    name = "Go: Depurar pacote atual (main)",
                    request = "launch",
                    program = "${fileDirname}",
                },
                {
                    type = "delve",
                    name = "Go: Depurar arquivo atual",
                    request = "launch",
                    program = "${file}",
                },
                {
                    type = "delve",
                    name = "Go: Depurar teste do pacote",
                    request = "launch",
                    mode = "test",
                    program = "${fileDirname}",
                },
                {
                    type = "delve",
                    name = "Go: Depurar teste do arquivo",
                    request = "launch",
                    mode = "test",
                    program = "${file}",
                },
                {
                    type = "delve",
                    name = "Go: Anexar a processo (Attach)",
                    request = "attach",
                    mode = "local",
                    processId = require("dap.utils").pick_process,
                },
            }

            -- Ícones de breakpoints na coluna de sinais (gutter)
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition",
                { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped",
                { text = "▶", texthl = "DiagnosticOk", linehl = "CursorLine", numhl = "CursorLine" })

            -- Encerramento e restauração limpa da tela
            local function terminate_dap()
                dap.terminate()
                dapui.close()
                vim.cmd("silent! bd! [dap-terminal]")
            end

            -- Atalhos padrão VS Code (F-keys)
            vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Iniciar / Continuar" })
            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Alternar Breakpoint" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Passar linha (Step Over)" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Entrar na função (Step Into)" })
            vim.keymap.set("n", "<S-F11>", dap.step_out, { desc = "Debug: Sair da função (Step Out)" })
            vim.keymap.set("n", "<S-F5>", terminate_dap, { desc = "Debug: Encerrar Debug e Fechar Painéis" })

            -- Atalhos sob o grupo <leader>d
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Alternar Breakpoint" })
            vim.keymap.set("n", "<leader>dB", function()
                vim.ui.input({ prompt = "Condição do breakpoint: " }, function(condition)
                    if condition and condition ~= "" then dap.set_breakpoint(condition) end
                end)
            end, { desc = "Breakpoint condicional" })
            vim.keymap.set({ "n", "v" }, "<leader>de", function() dapui.eval() end,
                { desc = "Avaliar expressão no debug" })
            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Iniciar / Continuar Debug" })
            vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Passar linha (Step Over)" })
            vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Entrar na função (Step Into)" })
            vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Sair da função (Step Out)" })
            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Alternar painel da UI" })
            vim.keymap.set("n", "<leader>dt", terminate_dap, { desc = "Encerrar Debug e Fechar Painéis" })
        end,
    },
}
