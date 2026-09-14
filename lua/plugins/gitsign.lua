-- ~/.config/nvim/lua/plugins/gitsigns.lua
return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "▔" },
                changedelete = { text = "▎" },
            },
            current_line_blame = true, -- Mostra autor e commit da linha atual em cinza claro
            current_line_blame_opts = {
                delay = 300,
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navegar entre alterações (hunks)
                map("n", "]h", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.next_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Próxima alteração Git" })

                map("n", "[h", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Alteração Git anterior" })

                -- Ações Git sob o prefixo <leader>g
                map("n", "<leader>gp", gs.preview_hunk, { desc = "Pré-visualizar alteração (Hunk)" })
                map("n", "<leader>gr", gs.reset_hunk, { desc = "Reverter alteração atual" })
                map("n", "<leader>gb", gs.blame_line, { desc = "Ver autor da linha (Blame)" })
            end,
        },
    },
}
