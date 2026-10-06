local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("UserLspAutoHover", { clear = true })
    local timer
    local generation = 0

    local function cancel()
        generation = generation + 1
        if timer then
            if not timer:is_closing() then
                timer:stop()
                timer:close()
            end
            timer = nil
        end
    end

    local function show()
        if vim.g.disable_auto_hover or vim.api.nvim_get_mode().mode ~= "n" then
            return
        end
        if vim.bo.buftype ~= "" or vim.api.nvim_win_get_config(0).relative ~= "" then
            return
        end
        local cmp = package.loaded.cmp
        if vim.fn.pumvisible() ~= 0 or (cmp and cmp.visible()) then
            return
        end
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local char = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
        if char == "" or char:match("%s") then
            return
        end
        if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" }) == 0 then
            return
        end

        vim.lsp.buf.hover({
            silent = true,
            focus = false,
            border = "rounded",
            max_width = 80,
            max_height = 20,
            close_events = { "CursorMoved", "CursorMovedI", "InsertEnter", "InsertCharPre", "BufHidden" },
        })
    end

    -- Timer próprio: funciona também após Esc, ao trocar de arquivo e com FixCursorHold.
    vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter", "WinEnter", "CursorMoved", "InsertLeave" }, {
        group = group,
        desc = "Mostrar documentação após 300 ms com o cursor parado",
        callback = function()
            cancel()
            local request = generation
            local bufnr = vim.api.nvim_get_current_buf()
            local winid = vim.api.nvim_get_current_win()
            timer = vim.defer_fn(function()
                if request ~= generation then
                    return
                end
                timer = nil
                if vim.api.nvim_get_current_buf() == bufnr and vim.api.nvim_get_current_win() == winid then
                    show()
                end
            end, 300)
        end,
    })
    vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave", "WinLeave" }, {
        group = group,
        callback = cancel,
    })
end

return M
