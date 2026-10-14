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
    local root = vim.fs.root(directory, {
        "pyproject.toml",
        "uv.lock",
        "poetry.lock",
        "Pipfile",
        "requirements.txt",
        "setup.py",
        ".venv",
        ".git",
    })
    return root or directory
end

function M.has_uv()
    local exe = vim.fn.exepath("uv")
    if exe == "" then
        return false
    end
    local root = M.root()
    return vim.fn.filereadable(vim.fs.joinpath(root, "uv.lock")) == 1
        or vim.fn.filereadable(vim.fs.joinpath(root, "pyproject.toml")) == 1
end

function M.python_bin()
    local venv = vim.env.VIRTUAL_ENV
    if venv and vim.fn.filereadable(vim.fs.joinpath(venv, "bin", "python")) == 1 then
        return vim.fs.joinpath(venv, "bin", "python")
    end

    local root = M.root()
    local local_venv = vim.fs.joinpath(root, ".venv", "bin", "python")
    if vim.fn.filereadable(local_venv) == 1 then
        return local_venv
    end

    local exe = vim.fn.exepath("python3")
    if exe ~= "" then
        return exe
    end
    exe = vim.fn.exepath("python")
    return exe ~= "" and exe or "python3"
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

function M.run(extra_args)
    local root = M.root()
    local file = vim.fn.expand("%")
    local cmd

    local has_main = vim.fn.filereadable(vim.fs.joinpath(root, "main.py")) == 1
        or vim.fn.filereadable("main.py") == 1
        or (file ~= "" and vim.fn.fnamemodify(file, ":t") == "main.py")

    local target = ""
    if file ~= "" and file:match("%.py$") then
        target = vim.fn.shellescape(file)
    elseif has_main then
        target = "main.py"
    end

    if M.has_uv() then
        local uv = vim.fn.exepath("uv")
        cmd = string.format("%s run %s", vim.fn.shellescape(uv), target ~= "" and target or "main.py")
    else
        local py = M.python_bin()
        cmd = string.format("%s %s", vim.fn.shellescape(py), target ~= "" and target or "main.py")
    end

    if extra_args and #extra_args > 0 then
        cmd = cmd .. " " .. table.concat(extra_args, " ")
    end
    run_in_terminal(cmd)
end

function M.test(file_only)
    local ok_neotest, neotest = pcall(require, "neotest")
    local file = vim.fn.expand("%")
    if ok_neotest then
        if file_only and file ~= "" then
            neotest.run.run(file)
        else
            neotest.run.run()
        end
    else
        local cmd
        if M.has_uv() then
            cmd = "uv run pytest -v"
        else
            local root = M.root()
            local venv_pytest = vim.fs.joinpath(root, ".venv", "bin", "pytest")
            local pytest = vim.fn.filereadable(venv_pytest) == 1 and venv_pytest or "pytest"
            cmd = string.format("%s -v", vim.fn.shellescape(pytest))
        end
        if file_only and file ~= "" then
            cmd = cmd .. " " .. vim.fn.shellescape(file)
        end
        run_in_terminal(cmd)
    end
end

function M.lint()
    local ruff = vim.fn.exepath("ruff")
    if ruff == "" then
        local mason_ruff = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "ruff")
        if vim.fn.executable(mason_ruff) == 1 then
            ruff = mason_ruff
        end
    end

    if ruff ~= "" then
        run_in_terminal(vim.fn.shellescape(ruff) .. " check .")
    else
        notify("Ruff não encontrado (:MasonInstall ruff).", vim.log.levels.WARN)
    end
end

function M.select_venv()
    local ok, _ = pcall(vim.cmd, "VenvSelect")
    if not ok then
        notify("Comando :VenvSelect não disponível. Verifique se o plugin venv-selector está instalado.", vim.log.levels.WARN)
    end
end

function M.info()
    local root = M.root()
    local py = M.python_bin()
    local py_ver = vim.fn.executable(py) == 1
        and vim.fn.system({ py, "--version" }):gsub("\n", "")
        or "não encontrado"

    local basedpyright_clients = vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })
    local ruff_clients = vim.lsp.get_clients({ bufnr = 0, name = "ruff" })

    local mason_debugpy = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "debugpy", "venv", "bin", "python")
    local has_debugpy = vim.fn.filereadable(mason_debugpy) == 1

    local venv_active = vim.env.VIRTUAL_ENV or "nenhum (ambiente global / do sistema)"
    local uv_active = M.has_uv() and "sim (projeto uv detectado)" or "não"

    notify(table.concat({
        "📁 Raiz do Projeto: " .. root,
        "🐍 Interpretador Python: " .. py .. " (" .. py_ver .. ")",
        "🌐 Virtualenv Ativo: " .. venv_active,
        "⚡ Projeto UV: " .. uv_active,
        "🔍 Basedpyright (LSP): " .. (#basedpyright_clients > 0 and "ativo" or "inativo"),
        "🧹 Ruff (Linter/LSP): " .. (#ruff_clients > 0 and "ativo" or "inativo"),
        "🐞 Debugpy (DAP): " .. (has_debugpy and "instalado no Mason" or "não instalado"),
    }, "\n"))
end

function M.setup()
    if configured then
        return
    end
    configured = true

    vim.api.nvim_create_user_command("PythonRun", function(opts)
        M.run(opts.fargs)
    end, { nargs = "*", desc = "Python: Executar projeto ou arquivo" })

    vim.api.nvim_create_user_command("PythonTest", function()
        M.test(false)
    end, { desc = "Python: Rodar teste mais próximo" })

    vim.api.nvim_create_user_command("PythonTestFile", function()
        M.test(true)
    end, { desc = "Python: Rodar testes do arquivo" })

    vim.api.nvim_create_user_command("PythonDebug", function()
        require("dap").continue()
    end, { desc = "Python: Iniciar Debug (DAP)" })

    vim.api.nvim_create_user_command("PythonVenv", M.select_venv, { desc = "Python: Selecionar ambiente virtual (Venv)" })
    vim.api.nvim_create_user_command("PythonLint", M.lint, { desc = "Python: Executar linter (ruff check)" })
    vim.api.nvim_create_user_command("PythonInfo", M.info, { desc = "Python: Mostrar ambiente e status" })
    vim.api.nvim_create_user_command("PythonHelp", function()
        vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(vim.fn.stdpath("config"), "README-PYTHON.md")))
    end, { desc = "Python: Guia de uso" })
end

function M.attach(buf)
    M.setup()
    buf = buf or vim.api.nvim_get_current_buf()

    -- Indentação padrão oficial PEP 8 (4 espaços)
    vim.bo[buf].expandtab = true
    vim.bo[buf].tabstop = 4
    vim.bo[buf].shiftwidth = 4
    vim.bo[buf].softtabstop = 4

    local mappings = {
        Pr = { "PythonRun", "Python: Executar projeto / arquivo" },
        Pt = { "PythonTest", "Python: Rodar teste mais próximo" },
        Pf = { "PythonTestFile", "Python: Rodar testes do arquivo" },
        Pd = { "PythonDebug", "Python: Iniciar Debug (DAP)" },
        Pv = { "PythonVenv", "Python: Selecionar ambiente virtual (Venv)" },
        Pl = { "PythonLint", "Python: Executar linter (ruff check)" },
        Pi = { "PythonInfo", "Python: Mostrar ambiente" },
        ["P?"] = { "PythonHelp", "Python: Guia de uso" },
        cx = { "PythonRun", "Python: Executar projeto / arquivo" },
        ct = { "PythonTest", "Python: Rodar teste mais próximo" },
        cv = { "PythonVenv", "Python: Selecionar ambiente virtual (Venv)" },
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

    vim.b[buf].undo_ftplugin = (vim.b[buf].undo_ftplugin and vim.b[buf].undo_ftplugin .. " | " or "")
        .. table.concat(undo, " | ")
end

return M
