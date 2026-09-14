-- ~/.config/nvim/lua/plugins/bufferline.lua
return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "famiu/bufdelete.nvim", -- Gerencia o fechamento seguro de buffers
        },
        keys = {
            { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer anterior" },
            { "<S-l>",      "<cmd>BufferLineCycleNext<cr>", desc = "Próximo buffer" },
            { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Fixar buffer (Pin)" },

            -- Fechar apenas o buffer atual sem quebrar layout nem fechar o Neovim
            {
                "<leader>bd",
                function()
                    require("bufdelete").bufdelete(0, false)
                end,
                desc = "Fechar buffer atual",
            },

            -- Fechar todos os buffers mantendo um buffer vazio e a Tree intacta
            {
                "<leader>bw",
                function()
                    local bd = require("bufdelete")
                    local buffers = vim.tbl_filter(function(b)
                        return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
                    end, vim.api.nvim_list_bufs())

                    -- Cria um buffer vazio de apoio para a janela de edição não sumir
                    local scratch = vim.api.nvim_create_buf(true, false)
                    vim.api.nvim_win_set_buf(0, scratch)

                    for _, b in ipairs(buffers) do
                        pcall(bd.bufdelete, b, false)
                    end
                end,
                desc = "Fechar todos os buffers",
            },
        },
        opts = {
            options = {
                mode = "buffers",
                separator_style = "slant",
                always_show_bufferline = true,
                show_buffer_close_icons = false,
                show_close_icon = false,
                diagnostics = "nvim_lsp",
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Explorador de Arquivos",
                        highlight = "Directory",
                        text_align = "left",
                        separator = true,
                    },
                },
            },
        },
    },
}
