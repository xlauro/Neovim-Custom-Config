local M = {}

local configured = false

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Go" })
end

function M.root(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    if vim.b[buf].go_root then
        return vim.b[buf].go_root
    end
    local file = vim.api.nvim_buf_get_name(buf)
    local directory = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
    local root = vim.fs.root(directory, { "go.work", "go.mod", ".git" })
    return root or directory
end

function M.go_bin()
    local exe = vim.fn.exepath("go")
    return exe ~= "" and exe or "go"
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
    local go = M.go_bin()
    local cmd
    local has_main = vim.fn.filereadable(vim.fs.joinpath(root, "main.go")) == 1
        or vim.fn.filereadable("main.go") == 1
        or (file ~= "" and vim.fn.fnamemodify(file, ":t") == "main.go")

    if has_main then
        cmd = string.format("%s run .", vim.fn.shellescape(go))
    elseif file ~= "" and file:match("%.go$") then
        cmd = string.format("%s run %s", vim.fn.shellescape(go), vim.fn.shellescape(file))
    else
        cmd = string.format("%s run .", vim.fn.shellescape(go))
    end

    if extra_args and #extra_args > 0 then
        cmd = cmd .. " " .. table.concat(extra_args, " ")
    end
    run_in_terminal(cmd)
end

function M.build(extra_args)
    local root = M.root()
    local file = vim.fn.expand("%")
    local go = M.go_bin()
    local has_module = vim.fn.filereadable(vim.fs.joinpath(root, "go.mod")) == 1
        or vim.fn.filereadable(vim.fs.joinpath(root, "go.work")) == 1

    local cmd
    if has_module then
        cmd = string.format("%s build ./...", vim.fn.shellescape(go))
    elseif file ~= "" and file:match("%.go$") then
        cmd = string.format("%s build %s", vim.fn.shellescape(go), vim.fn.shellescape(file))
    else
        cmd = string.format("%s build ./...", vim.fn.shellescape(go))
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
        local go = M.go_bin()
        local cmd
        if file_only and file ~= "" then
            cmd = string.format("%s test -v %s", vim.fn.shellescape(go), vim.fn.shellescape(file))
        else
            cmd = string.format("%s test -v ./...", vim.fn.shellescape(go))
        end
        run_in_terminal(cmd)
    end
end

function M.tidy()
    local go = M.go_bin()
    run_in_terminal(string.format("%s mod tidy", vim.fn.shellescape(go)))
end

function M.lint()
    local linter = vim.fn.exepath("golangci-lint")
    if linter == "" then
        local mason_linter = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "golangci-lint")
        if vim.fn.executable(mason_linter) == 1 then
            linter = mason_linter
        end
    end
    if linter ~= "" then
        run_in_terminal(vim.fn.shellescape(linter) .. " run")
    else
        notify("golangci-lint não encontrado no PATH nem no Mason (:MasonInstall golangci-lint).", vim.log.levels.WARN)
    end
end

function M.coverage()
    local go = M.go_bin()
    local go_esc = vim.fn.shellescape(go)
    local cmd = string.format("%s test -coverprofile=coverage.out ./... && %s tool cover -html=coverage.out", go_esc, go_esc)
    run_in_terminal(cmd)
end

function M.info()
    local root = M.root()
    local go = M.go_bin()
    local go_ver = vim.fn.executable(go) == 1
        and vim.fn.system({ go, "version" }):gsub("\n", "")
        or "não instalado"
    local gopls_clients = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })

    local dlv_path = vim.fn.exepath("dlv")
    if dlv_path == "" then
        local mason_dlv = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "dlv")
        if vim.fn.executable(mason_dlv) == 1 then
            dlv_path = mason_dlv
        end
    end

    local linter_path = vim.fn.exepath("golangci-lint")
    if linter_path == "" then
        local mason_linter = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "golangci-lint")
        if vim.fn.executable(mason_linter) == 1 then
            linter_path = mason_linter
        end
    end

    notify(table.concat({
        "📁 Raiz do Módulo: " .. root,
        "🐹 Compilador Go: " .. go_ver,
        "🔍 Gopls (LSP): " .. (#gopls_clients > 0 and "ativo" or "inativo"),
        "🐞 Delve (DAP): " .. (dlv_path ~= "" and ("instalado (" .. dlv_path .. ")") or "não instalado"),
        "✨ GolangCI-Lint: " .. (linter_path ~= "" and ("instalado (" .. linter_path .. ")") or "não instalado"),
    }, "\n"))
end

function M.setup()
    if configured then
        return
    end
    configured = true

    vim.api.nvim_create_user_command("GoRun", function(opts)
        M.run(opts.fargs)
    end, { nargs = "*", desc = "Go: Executar projeto ou arquivo" })

    vim.api.nvim_create_user_command("GoBuild", function(opts)
        M.build(opts.fargs)
    end, { nargs = "*", desc = "Go: Compilar projeto ou arquivo" })

    vim.api.nvim_create_user_command("GoTest", function()
        M.test(false)
    end, { desc = "Go: Rodar teste mais próximo" })

    vim.api.nvim_create_user_command("GoTestFile", function()
        M.test(true)
    end, { desc = "Go: Rodar testes do arquivo" })

    vim.api.nvim_create_user_command("GoModTidy", M.tidy, { desc = "Go: Sincronizar módulos (go mod tidy)" })
    vim.api.nvim_create_user_command("GoLint", M.lint, { desc = "Go: Executar linter (golangci-lint)" })
    vim.api.nvim_create_user_command("GoCoverage", M.coverage, { desc = "Go: Relatório de cobertura de testes" })
    vim.api.nvim_create_user_command("GoInfo", M.info, { desc = "Go: Mostrar ambiente" })
    vim.api.nvim_create_user_command("GoHelp", function()
        vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(vim.fn.stdpath("config"), "README-GO.md")))
    end, { desc = "Go: Guia de uso" })
end

function M.attach(buf)
    M.setup()
    buf = buf or vim.api.nvim_get_current_buf()

    -- Indentação padrão oficial Go (Tabs reais com largura 4)
    vim.bo[buf].expandtab = false
    vim.bo[buf].tabstop = 4
    vim.bo[buf].shiftwidth = 4
    vim.bo[buf].softtabstop = 4

    local mappings = {
        Gr = { "GoRun", "Go: Executar projeto / arquivo" },
        Gb = { "GoBuild", "Go: Compilar projeto (go build)" },
        Gt = { "GoTest", "Go: Rodar teste mais próximo" },
        Gf = { "GoTestFile", "Go: Rodar testes do arquivo" },
        Gm = { "GoModTidy", "Go: Sincronizar módulos (go mod tidy)" },
        Gl = { "GoLint", "Go: Executar linter (golangci-lint)" },
        Gc = { "GoCoverage", "Go: Relatório de cobertura de testes" },
        Gi = { "GoInfo", "Go: Mostrar ambiente" },
        ["G?"] = { "GoHelp", "Go: Guia de uso" },
        cx = { "GoRun", "Go: Executar projeto / arquivo" },
        cb = { "GoBuild", "Go: Compilar projeto (go build)" },
        ct = { "GoTest", "Go: Rodar teste mais próximo" },
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

    vim.keymap.set("n", "<leader>Gd", function()
        require("dap").continue()
    end, {
        buffer = buf,
        desc = "Go: Iniciar Debug (DAP)",
        silent = true,
    })
    table.insert(undo, "silent! nunmap <buffer> <leader>Gd")

    vim.b[buf].undo_ftplugin = (vim.b[buf].undo_ftplugin and vim.b[buf].undo_ftplugin .. " | " or "")
        .. table.concat(undo, " | ")
end

return M
