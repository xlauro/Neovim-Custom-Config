-- ~/.config/nvim/lua/config/autocmds.lua
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Destaque visual temporário ao copiar texto (yank)
autocmd("TextYankPost", {
    desc = "Destacar texto ao copiar",
    group = augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
    end,
})

-- Sincronização automática de alterações externas nos buffers
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    desc = "Recarrega buffers modificados externamente no sistema de arquivos",
    group = augroup("auto_read", { clear = true }),
    callback = function()
        if vim.fn.mode() ~= "c" then
            vim.cmd("checktime")
        end
    end,
})
