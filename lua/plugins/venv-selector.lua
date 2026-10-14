-- ~/.config/nvim/lua/plugins/venv-selector.lua
return {
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-telescope/telescope.nvim",
            "mfussenegger/nvim-dap",
        },
        cmd = "VenvSelect",
        ft = "python",
        keys = {
            { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Selecionar ambiente virtual (Venv)" },
            { "<leader>Pv", "<cmd>VenvSelect<cr>", desc = "Python: Selecionar ambiente virtual (Venv)" },
        },
        opts = {
            settings = {
                options = {
                    notify_user_on_venv_activation = true,
                },
            },
        },
    },
}
