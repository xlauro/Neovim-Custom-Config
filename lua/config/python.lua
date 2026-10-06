local M = {}

local configured = false

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Python" })
end

function M.root(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    if vim.b[buf].python_root then
        return vim.b[buf].python_root
    end
    local file = vim.api.nvim_buf_get_name(buf)
    local directory = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
    local root = vim.fs.root(directory, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git", ".venv" })
    return root or directory
end

function M.python_bin(root)
    root = root or M.root()
    local venv = os.getenv("VIRTUAL_ENV")
    if venv and vim.fn.filereadable(venv .. "/bin/python") == 1 then
        return venv .. "/bin/python"
    end
    local local_venv = vim.fs.joinpath(root, ".venv", "bin", "python")
    if vim.fn.filereadable(local_venv) == 1 then
        return local_venv
    end
    local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    if vim.fn.filereadable(mason_debugpy) == 1 then
        return mason_debugpy
    end
    return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
end

local function run_in_terminal(cmd)
    local ok_term, toggleterm = pcall(require, "toggleterm")
    if ok_term then
        vim.cmd("w")
        local height = math.floor(vim.o.lines * 0.35)
        toggleterm.exec(cmd, 1, height, nil, "horizontal")
    else
        vim.cmd("split | terminal " .. cmd)
    end
end

function M.run_file(extra_args)
    local file = vim.fn.expand("%")
    if file == "" then
        notify("Nenhum arquivo Python aberto.", vim.log.levels.WARN)
        return
    end
    local root = M.root()
    local cmd
    if vim.fn.executable("uv") == 1 and vim.fn.filereadable(vim.fs.joinpath(root, "pyproject.toml")) == 1 then
        cmd = string.format("uv run python %s", vim.fn.shellescape(file))
    else
        local py = M.python_bin(root)
        cmd = string.format("%s %s", vim.fn.shellescape(py), vim.fn.shellescape(file))
    end
    if extra_args and #extra_args > 0 then
        cmd = cmd .. " " .. table.concat(extra_args, " ")
    end
    run_in_terminal(cmd)
end

function M.run_server()
    local root = M.root()
    local default_app = "src.main:app"
    if vim.fn.filereadable(vim.fs.joinpath(root, "main.py")) == 1 then
        default_app = "main:app"
    elseif vim.fn.filereadable(vim.fs.joinpath(root, "src", "api.py")) == 1 then
        default_app = "src.api:app"
    end

    local app = vim.fn.input("Módulo FastAPI / Uvicorn [padrão: " .. default_app .. "]: ")
    if not app or app == "" then
        app = default_app
    end

    local cmd
    if vim.fn.executable("uv") == 1 then
        cmd = string.format("uv run uvicorn %s --reload --port 8000", app)
    else
        local py = M.python_bin(root)
        cmd = string.format("%s -m uvicorn %s --reload --port 8000", vim.fn.shellescape(py), app)
    end
    run_in_terminal(cmd)
end

function M.run_tests(file_only)
    local ok_neotest, neotest = pcall(require, "neotest")
    if ok_neotest then
        if file_only then
            neotest.run.run(vim.fn.expand("%"))
        else
            neotest.run.run()
        end
    else
        local root = M.root()
        local target = file_only and vim.fn.expand("%") or ""
        local cmd = vim.fn.executable("uv") == 1 and ("uv run pytest " .. target) or ("pytest " .. target)
        run_in_terminal(cmd)
    end
end

function M.sync()
    if vim.fn.executable("uv") == 1 then
        run_in_terminal("uv sync")
    else
        notify("uv não encontrado no PATH.", vim.log.levels.WARN)
    end
end

function M.info()
    local root = M.root()
    local python = M.python_bin(root)
    local uv_ver = vim.fn.executable("uv") == 1
        and vim.fn.system("uv --version"):gsub("\n", "")
        or "não instalado"
    local basedpyright_clients = vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })
    local ruff_clients = vim.lsp.get_clients({ bufnr = 0, name = "ruff" })

    notify(table.concat({
        "📁 Raiz do Projeto: " .. root,
        "🐍 Interpretador Python: " .. python,
        "⚡ Gerenciador uv: " .. uv_ver,
        "🔍 Basedpyright: " .. (#basedpyright_clients > 0 and "ativo" or "inativo"),
        "✨ Ruff: " .. (#ruff_clients > 0 and "ativo" or "inativo"),
    }, "\n"))
end

function M.setup()
    if configured then
        return
    end
    configured = true

    vim.api.nvim_create_user_command("PyRun", function(opts)
        M.run_file(opts.fargs)
    end, { nargs = "*", desc = "Python: Executar arquivo atual" })

    vim.api.nvim_create_user_command("PyServer", M.run_server, { desc = "Python: Iniciar servidor FastAPI/Uvicorn" })
    vim.api.nvim_create_user_command("PyTest", function() M.run_tests(false) end, { desc = "Python: Rodar teste mais próximo" })
    vim.api.nvim_create_user_command("PyTestFile", function() M.run_tests(true) end, { desc = "Python: Rodar testes do arquivo" })
    vim.api.nvim_create_user_command("PySync", M.sync, { desc = "Python: Sincronizar dependências com uv" })
    vim.api.nvim_create_user_command("PyInfo", M.info, { desc = "Python: Mostrar ambiente e interpretador" })
    vim.api.nvim_create_user_command("PyHelp", function()
        vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(vim.fn.stdpath("config"), "README-PYTHON.md")))
    end, { desc = "Python: Abrir documentação de referência" })
end

function M.attach(buf)
    M.setup()
    buf = buf or vim.api.nvim_get_current_buf()

    -- Indentação padrão PEP 8
    vim.bo[buf].expandtab = true
    vim.bo[buf].tabstop = 4
    vim.bo[buf].softtabstop = 4
    vim.bo[buf].shiftwidth = 4

    local mappings = {
        pr = { "PyRun", "Python: Executar arquivo" },
        ps = { "PyServer", "Python: Iniciar servidor FastAPI/Uvicorn" },
        pt = { "PyTest", "Python: Rodar teste mais próximo" },
        pf = { "PyTestFile", "Python: Rodar testes do arquivo" },
        py = { "PySync", "Python: Sincronizar dependências (uv sync)" },
        pi = { "PyInfo", "Python: Mostrar ambiente" },
        ["p?"] = { "PyHelp", "Python: Guia de uso" },
    }

    local undo = { "setlocal expandtab< tabstop< softtabstop< shiftwidth<" }
    for keys, mapping in pairs(mappings) do
        vim.keymap.set("n", "<leader>" .. keys, "<cmd>" .. mapping[1] .. "<cr>", {
            buffer = buf,
            desc = mapping[2],
            silent = true,
        })
        table.insert(undo, "silent! nunmap <buffer> <leader>" .. keys)
    end

    -- Atalhos adicionais específicos para testes e virtualenv se plugins existirem
    vim.keymap.set("n", "<leader>pv", "<cmd>VenvSelect<cr>", {
        buffer = buf,
        desc = "Python: Selecionar Virtualenv",
        silent = true,
    })
    table.insert(undo, "silent! nunmap <buffer> <leader>pv")

    vim.keymap.set("n", "<leader>pd", function()
        require("dap").continue()
    end, {
        buffer = buf,
        desc = "Python: Iniciar Debug (DAP)",
        silent = true,
    })
    table.insert(undo, "silent! nunmap <buffer> <leader>pd")

    vim.b[buf].undo_ftplugin = (vim.b[buf].undo_ftplugin and vim.b[buf].undo_ftplugin .. " | " or "")
        .. table.concat(undo, " | ")
end

return M
