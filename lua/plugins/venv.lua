-- ~/.config/nvim/lua/plugins/venv.lua
return {
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            { "mfussenegger/nvim-dap", optional = true },
            "nvim-telescope/telescope.nvim",
        },
        ft = "python",
        cmd = "VenvSelect",
        opts = {
            settings = {
                options = {
                    notify_user_on_venv_activation = true,
                },
            },
        },
        keys = {
            { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Python: Selecionar Virtualenv (uv / .venv)" },
            { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Selecionar Virtualenv (uv / .venv)" },
        },
    },
}
