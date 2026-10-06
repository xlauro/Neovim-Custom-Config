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
            { "<leader>pd", desc = "Python: Iniciar Debug (DAP)" },
        },
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap-python",
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

            -- 1. Adapter CodeLLDB (C, C++, Rust, Zig)
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

            -- 3. Adapter Debugpy (Python)
            local function get_python_path()
                local venv = os.getenv("VIRTUAL_ENV")
                if venv and vim.fn.filereadable(venv .. "/bin/python") == 1 then
                    return venv .. "/bin/python"
                end
                local cwd_venv = vim.fn.getcwd() .. "/.venv/bin/python"
                if vim.fn.filereadable(cwd_venv) == 1 then
                    return cwd_venv
                end
                local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
                if vim.fn.filereadable(mason_debugpy) == 1 then
                    return mason_debugpy
                end
                return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
            end

            dap.adapters.python = function(cb, config)
                if config.request == "attach" then
                    local port = (config.connect or config).port
                    local host = (config.connect or config).host or "127.0.0.1"
                    cb({
                        type = "server",
                        port = assert(port, "`connect.port` é obrigatório para anexar ao debugpy"),
                        host = host,
                        options = {
                            source_filetype = "python",
                        },
                    })
                else
                    cb({
                        type = "executable",
                        command = get_python_path(),
                        args = { "-m", "debugpy.adapter" },
                        options = {
                            source_filetype = "python",
                        },
                    })
                end
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

            local function pick_zig_binary(root, done)
                local bin_dir = root .. "/zig-out/bin"
                local binaries = {}
                local scan = vim.uv.fs_scandir(bin_dir)
                if scan then
                    while true do
                        local name = vim.uv.fs_scandir_next(scan)
                        if not name then break end
                        local path = bin_dir .. "/" .. name
                        local stat = vim.uv.fs_stat(path)
                        if stat and stat.type == "file" and vim.fn.executable(path) == 1 then
                            table.insert(binaries, path)
                        end
                    end
                end
                table.sort(binaries)

                local function manual_path()
                    vim.ui.input({
                        prompt = "Executável Zig: ",
                        default = (vim.fn.isdirectory(bin_dir) == 1 and bin_dir or root) .. "/",
                        completion = "file",
                    }, function(path)
                        if not path or path == "" then return done(nil) end
                        path = vim.fs.normalize(path)
                        if path:sub(1, 1) ~= "/" then path = root .. "/" .. path end
                        local stat = vim.uv.fs_stat(path)
                        if not stat or stat.type ~= "file" or vim.fn.executable(path) ~= 1 then
                            vim.notify("Executável Zig inválido: " .. path, vim.log.levels.ERROR)
                            return done(nil)
                        end
                        done(path)
                    end)
                end

                if #binaries == 0 then return manual_path() end
                table.insert(binaries, "Informar outro caminho…")
                vim.ui.select(binaries, {
                    prompt = "Executável Zig para depurar:",
                    format_item = function(path)
                        return vim.startswith(path, bin_dir .. "/") and path:sub(#bin_dir + 2) or path
                    end,
                }, function(path, index)
                    if not path then return done(nil) end
                    if index == #binaries then return manual_path() end
                    done(path)
                end)
            end

            -- Captura buffer/raiz antes de abrir seletores e aguarda builds sem bloquear a UI.
            local function zig_launch(name, prepare)
                return setmetatable({ name = name, type = "codelldb", request = "launch" }, {
                    __call = function()
                        local buf = vim.api.nvim_get_current_buf()
                        local root = require("config.zig").root(buf)
                        return {
                            name = name,
                            type = "codelldb",
                            request = "launch",
                            cwd = root,
                            terminal = "integrated",
                            expressions = "simple",
                            stopOnEntry = false,
                            program = function()
                                return coroutine.create(function(dap_run_co)
                                    local finished = false
                                    local function done(path)
                                        if finished then return end
                                        finished = true
                                        coroutine.resume(dap_run_co, path or dap.ABORT)
                                    end
                                    if vim.fn.executable(codelldb_path) ~= 1 then
                                        vim.notify("CodeLLDB indisponível. Instale com :MasonInstall codelldb.",
                                            vim.log.levels.ERROR)
                                        return done(nil)
                                    end
                                    local ok, err = pcall(prepare, buf, root, done)
                                    if not ok then
                                        vim.notify("Não foi possível preparar o debug Zig: " .. tostring(err),
                                            vim.log.levels.ERROR)
                                        done(nil)
                                    end
                                end)
                            end,
                        }
                    end,
                })
            end

            dap.configurations.zig = {
                zig_launch("Zig: compilar projeto (Debug) e depurar", function(buf, root, done)
                    if vim.fn.filereadable(root .. "/build.zig") ~= 1 then
                        vim.notify("Sem build.zig. Use o perfil de arquivo independente.", vim.log.levels.WARN)
                        return done(nil)
                    end
                    local task = require("config.zig").run_task({ "build", "-Doptimize=Debug" }, {
                        buf = buf,
                        cwd = root,
                        title = "Zig: compilar para depuração",
                        callback = function(result)
                            if result.code ~= 0 then return done(nil) end
                            pick_zig_binary(root, done)
                        end,
                    })
                    if not task then done(nil) end
                end),
                zig_launch("Zig: depurar executável já compilado", function(_, root, done)
                    pick_zig_binary(root, done)
                end),
                zig_launch("Zig: compilar e depurar arquivo independente", function(buf, root, done)
                    local file = vim.api.nvim_buf_get_name(buf)
                    if file == "" or not file:match("%.zig$") then
                        vim.notify("Abra um arquivo .zig para depurar.", vim.log.levels.WARN)
                        return done(nil)
                    end
                    local cache = vim.fn.stdpath("cache") .. "/zig-debug/" .. vim.fn.sha256(file):sub(1, 16)
                    vim.fn.mkdir(cache, "p")
                    local binary = cache .. "/" .. vim.fn.fnamemodify(file, ":t:r")
                    local task = require("config.zig").run_task({
                        "build-exe", "-O", "Debug", "-fllvm", file, "-femit-bin=" .. binary,
                    }, {
                        buf = buf,
                        cwd = root,
                        title = "Zig: compilar arquivo para depuração",
                        callback = function(result)
                            done(result.code == 0 and binary or nil)
                        end,
                    })
                    if not task then done(nil) end
                end),
                {
                    name = "Zig: anexar a processo",
                    type = "codelldb",
                    request = "attach",
                    pid = require("dap.utils").pick_process,
                    cwd = function() return require("config.zig").root() end,
                    expressions = "simple",
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

            -- Configurações para Python
            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Python: Executar arquivo atual",
                    program = "${file}",
                    pythonPath = get_python_path,
                    console = "integratedTerminal",
                },
                {
                    type = "python",
                    request = "launch",
                    name = "Python: Executar arquivo com argumentos",
                    program = "${file}",
                    pythonPath = get_python_path,
                    args = function()
                        local args_str = vim.fn.input("Argumentos de linha de comando: ")
                        if args_str and args_str ~= "" then
                            return vim.split(args_str, " +")
                        end
                        return {}
                    end,
                    console = "integratedTerminal",
                },
                {
                    type = "python",
                    request = "launch",
                    name = "Python: Servidor FastAPI / Uvicorn (dev)",
                    module = "uvicorn",
                    pythonPath = get_python_path,
                    args = function()
                        local default_app = "src.main:app"
                        if vim.fn.filereadable("main.py") == 1 then
                            default_app = "main:app"
                        elseif vim.fn.filereadable("src/api.py") == 1 then
                            default_app = "src.api:app"
                        end
                        local app = vim.fn.input("Módulo FastAPI [padrão: " .. default_app .. "]: ")
                        if not app or app == "" then
                            app = default_app
                        end
                        return { app, "--reload", "--port", "8000" }
                    end,
                    jinja = true,
                    justMyCode = false,
                    console = "integratedTerminal",
                },
                {
                    type = "python",
                    request = "attach",
                    name = "Python: Anexar ao Processo (Attach via Porta)",
                    connect = function()
                        local host = vim.fn.input("Host [127.0.0.1]: ")
                        if not host or host == "" then host = "127.0.0.1" end
                        local port_str = vim.fn.input("Porta [5678]: ")
                        local port = tonumber(port_str) or 5678
                        return { host = host, port = port }
                    end,
                },
            }

            local ok_dap_python, dap_python = pcall(require, "dap-python")
            if ok_dap_python then
                dap_python.test_runner = "pytest"
            end

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
