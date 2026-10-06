local M = {}

local running = {}
local output_buffers = {}
local terminal_buffers = {}
local last_output = {}
local configured = false

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Zig" })
end

function M.root(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    if vim.b[buf].zig_root then
        return vim.b[buf].zig_root
    end
    if vim.bo[buf].buftype == "quickfix" then
        local context = vim.fn.getqflist({ context = 0 }).context
        if type(context) == "table" and context.zig_root then
            return context.zig_root
        end
    end
    local file = vim.api.nvim_buf_get_name(buf)
    local directory = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
    return vim.fs.root(directory, { "build.zig", "build.zig.zon" }) or directory
end

local function save_buffers(root)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == ""
            and vim.bo[buf].modified and (name == root or vim.startswith(name, root .. "/")) then
            local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
                vim.cmd.update()
            end)
            if not ok then
                notify("Não foi possível salvar: " .. tostring(err), vim.log.levels.ERROR)
                return false
            end
        end
    end
    return true
end

local function prepare(args, opts)
    local root = opts.cwd or M.root(opts.buf)
    if running[root] then
        notify("Já existe uma tarefa nesta raiz. Use :ZigStop para interromper.", vim.log.levels.WARN)
        return
    end
    local executable = vim.fn.exepath("zig")
    if executable == "" then
        notify("Zig não foi encontrado no PATH. Instale o compilador e reinicie o Neovim.", vim.log.levels.ERROR)
        return
    end
    if not save_buffers(root) then
        return
    end
    local command = { executable }
    vim.list_extend(command, args)
    return root, command
end

local function show_buffer(buf)
    local windows = vim.fn.win_findbuf(buf)
    if #windows > 0 then
        vim.api.nvim_set_current_win(windows[1])
    else
        vim.cmd("botright 12split")
        vim.api.nvim_win_set_buf(0, buf)
    end
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
end

local function output_buffer(root)
    local buf = output_buffers[root]
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        buf = vim.api.nvim_create_buf(false, true)
        output_buffers[root] = buf
        vim.api.nvim_buf_set_name(buf, "zig-output://" .. root)
        vim.bo[buf].bufhidden = "hide"
        vim.bo[buf].swapfile = false
        vim.bo[buf].filetype = "log"
        vim.b[buf].zig_root = root
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Fechar saída Zig" })
    end
    last_output[root] = buf
    return buf
end

local function write_output(buf, root, command, status, result)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    local lines = {
        "Raiz: " .. root,
        "$ " .. table.concat(vim.tbl_map(vim.fn.shellescape, command), " "),
        status,
        "",
    }
    if result then
        for _, stream in ipairs({ result.stdout or "", result.stderr or "" }) do
            vim.list_extend(lines, vim.split(stream, "\n", { plain = true, trimempty = true }))
        end
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
end

local function quickfix(root, title, result, open)
    local items = {}
    local output = (result.stderr or "") .. "\n" .. (result.stdout or "")
    for line in output:gmatch("[^\n]+") do
        line = line:gsub("\27%[[%d;]*m", "")
        local file, row, col, details = line:match("^(.-):(%d+):(%d+):%s*(.*)$")
        if file then
            local severity, message = details:match("^(%a+):%s*(.*)$")
            if file:sub(1, 1) ~= "/" then
                file = vim.fs.joinpath(root, file)
            end
            table.insert(items, {
                filename = vim.fs.normalize(file),
                lnum = tonumber(row),
                col = tonumber(col),
                text = message or details,
                type = severity == "error" and "E" or severity == "warning" and "W" or "I",
            })
        end
    end
    vim.fn.setqflist({}, "r", { title = title, items = items, context = { zig_root = root } })
    if open ~= false and result.code ~= 0 and #items > 0 then
        vim.cmd.copen()
    end
end

-- args contém os argumentos do Zig, sem o executável.
-- opts: buf, cwd, title, open_quickfix, callback(result).
-- result preserva code/signal/stdout/stderr e acrescenta cancelled.
-- Retorna o processo vim.system, ou nil se a tarefa não puder iniciar.
function M.run_task(args, opts)
    opts = opts or {}
    local root, command = prepare(args, opts)
    if not root then
        return
    end
    local title = opts.title or ("zig " .. table.concat(args, " "))
    local buf = output_buffer(root)
    write_output(buf, root, command, "Executando…")
    local task = {}
    running[root] = task
    local ok, process = pcall(vim.system, command, { cwd = root, text = true }, function(result)
        vim.schedule(function()
            if running[root] == task then
                running[root] = nil
            end
            result.cancelled = task.stopped == true or (result.signal or 0) ~= 0
            local success = result.code == 0 and not result.cancelled
            local status = result.cancelled and "Interrompido" or (success and "Concluído" or "Falhou")
            write_output(buf, root, command, status .. " (código " .. result.code .. ")", result)
            quickfix(root, title, result, opts.open_quickfix)
            notify(title .. ": " .. status:lower() .. ". Saída em :ZigOutput.",
                success and vim.log.levels.INFO or vim.log.levels.WARN)
            if opts.callback then
                opts.callback(result)
            end
        end)
    end)
    if not ok then
        running[root] = nil
        write_output(buf, root, command, "Não foi possível iniciar: " .. tostring(process))
        notify(tostring(process), vim.log.levels.ERROR)
        return
    end
    task.process = process
    notify(title .. "…")
    return process
end

local function run_terminal(args, opts)
    local root, command = prepare(args, opts)
    if not root then
        return
    end
    local previous = terminal_buffers[root]
    local buf = vim.api.nvim_create_buf(false, true)
    if previous and vim.api.nvim_buf_is_valid(previous) then
        for _, window in ipairs(vim.fn.win_findbuf(previous)) do
            vim.api.nvim_win_set_buf(window, buf)
        end
        vim.api.nvim_buf_delete(previous, { force = true })
    end
    terminal_buffers[root] = buf
    last_output[root] = buf
    vim.b[buf].zig_root = root
    vim.bo[buf].bufhidden = "hide"
    show_buffer(buf)
    local task = {}
    running[root] = task
    local ok, job = pcall(vim.fn.jobstart, command, {
        cwd = root,
        term = true,
        on_exit = function(_, code)
            vim.schedule(function()
                if running[root] == task then
                    running[root] = nil
                end
                notify("Execução " .. (task.stopped and "interrompida" or "encerrada") .. " (código " .. code .. ").")
            end)
        end,
    })
    if not ok or job <= 0 then
        running[root] = nil
        notify("Não foi possível iniciar o terminal Zig.", vim.log.levels.ERROR)
        return
    end
    task.job = job
    vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = buf, desc = "Sair do modo terminal" })
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Ocultar terminal Zig" })
    vim.cmd.startinsert()
end

function M.stop(buf)
    local task = running[M.root(buf)]
    if not task then
        notify("Nenhuma tarefa Zig em execução nesta raiz.")
        return
    end
    task.stopped = true
    if task.process then
        task.process:kill(15)
    elseif task.job then
        vim.fn.jobstop(task.job)
    end
end

function M.output(buf)
    local output = last_output[M.root(buf)]
    if output and vim.api.nvim_buf_is_valid(output) then
        show_buffer(output)
    else
        notify("Ainda não há saída Zig para esta raiz.")
    end
end

local function execute(action, extra)
    local buf = vim.api.nvim_get_current_buf()
    local root = M.root(buf)
    local file = vim.api.nvim_buf_get_name(buf)
    local project = vim.fn.filereadable(vim.fs.joinpath(root, "build.zig")) == 1
    local args
    if action == "check" then
        if not file:match("%.zig$") and not file:match("%.zon$") then
            notify("Abra um arquivo .zig ou .zon para verificar.", vim.log.levels.WARN)
            return
        end
        args = { "ast-check", file }
    elseif project and action ~= "test_file" then
        args = { "build" }
        if action ~= "build" then
            table.insert(args, action)
        end
        table.insert(args, "-Doptimize=Debug")
    else
        if not file:match("%.zig$") then
            notify("Esta tarefa requer um arquivo .zig ou um projeto com build.zig.", vim.log.levels.WARN)
            return
        end
        if action == "build" then
            -- Executáveis avulsos ficam ao lado do código, em zig-out/bin/<nome>.
            local out = vim.fs.joinpath(root, "zig-out", "bin")
            vim.fn.mkdir(out, "p")
            local name = vim.fn.fnamemodify(file, ":t:r")
            args = { "build-exe", file, "-O", "Debug", "-femit-bin=" .. vim.fs.joinpath(out, name) }
        elseif action == "run" then
            args = { "run", file, "-O", "Debug" }
        else
            args = { "test", file, "-O", "Debug" }
        end
    end
    vim.list_extend(args, extra or {})
    local opts = { buf = buf, cwd = root }
    if action == "run" then
        run_terminal(args, opts)
    else
        M.run_task(args, opts)
    end
end

function M.info()
    local root = M.root()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = "zls" })
    notify(table.concat({
        "Raiz: " .. root,
        "Zig: " .. (vim.fn.exepath("zig") ~= "" and vim.fn.exepath("zig") or "ausente"),
        "ZLS: " .. (#clients > 0 and "conectado" or "sem cliente neste buffer"),
        "Tarefa: " .. (running[root] and "em execução" or "nenhuma"),
        "Build/run/test usam os passos de build.zig; ZigTestFile testa o arquivo isoladamente.",
    }, "\n"))
end

function M.setup()
    if configured then
        return
    end
    configured = true
    for command, action in pairs({
        ZigBuild = "build", ZigRun = "run", ZigTest = "test", ZigTestFile = "test_file", ZigCheck = "check",
    }) do
        vim.api.nvim_create_user_command(command, function(opts)
            execute(action, opts.fargs)
        end, { nargs = "*", desc = "Zig: " .. action })
    end
    vim.api.nvim_create_user_command("ZigStop", function() M.stop() end, { desc = "Interromper tarefa Zig" })
    vim.api.nvim_create_user_command("ZigOutput", function() M.output() end, { desc = "Mostrar última saída Zig" })
    vim.api.nvim_create_user_command("ZigInfo", M.info, { desc = "Mostrar ambiente Zig" })
    vim.api.nvim_create_user_command("ZigHelp", function()
        vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(vim.fn.stdpath("config"), "README-ZIG.md")))
    end, { desc = "Abrir guia do ambiente Zig" })
end

function M.attach(buf)
    M.setup()
    buf = buf or vim.api.nvim_get_current_buf()
    vim.bo[buf].expandtab = true
    vim.bo[buf].tabstop = 4
    vim.bo[buf].softtabstop = 4
    vim.bo[buf].shiftwidth = 4
    local mappings = {
        zb = { "ZigBuild", "Zig: compilar (Debug)" },
        zr = { "ZigRun", "Zig: executar" },
        zt = { "ZigTest", "Zig: testar projeto" },
        zf = { "ZigTestFile", "Zig: testar arquivo" },
        zc = { "ZigCheck", "Zig: verificar arquivo" },
        zs = { "ZigStop", "Zig: interromper" },
        zo = { "ZigOutput", "Zig: mostrar saída" },
        zi = { "ZigInfo", "Zig: ambiente" },
        ["z?"] = { "ZigHelp", "Zig: guia de uso" },
        cb = { "ZigBuild", "Zig: compilar (Debug)" },
        cx = { "ZigRun", "Zig: executar" },
        ct = { "ZigTest", "Zig: testar projeto" },
    }
    local undo = { "setlocal expandtab< tabstop< softtabstop< shiftwidth<" }
    for keys, mapping in pairs(mappings) do
        vim.keymap.set("n", "<leader>" .. keys, "<cmd>" .. mapping[1] .. "<cr>", {
            buffer = buf, desc = mapping[2], silent = true,
        })
        table.insert(undo, "silent! nunmap <buffer> <leader>" .. keys)
    end
    vim.b[buf].undo_ftplugin = (vim.b[buf].undo_ftplugin and vim.b[buf].undo_ftplugin .. " | " or "")
        .. table.concat(undo, " | ")
end

return M
