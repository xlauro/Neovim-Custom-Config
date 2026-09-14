-- ~/.config/nvim/lua/plugins/tree.lua
return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        lazy = false, -- Impede o lazy-loading e carrega o plugin na inicialização
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle File Explorer" },
        },
        opts = {
            close_if_last_window = true,
            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
                follow_current_file = {
                    enabled = true,
                },
            },
        },
        init = function()
            vim.api.nvim_create_autocmd("VimEnter", {
                desc = "Abre o Neo-tree apenas se nenhum arquivo for passado",
                callback = function()
                    if vim.fn.argc() == 0 then
                        vim.schedule(function()
                            vim.cmd("Neotree show")
                        end)
                    end
                end,
            })
        end,
    },
}
