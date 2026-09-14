-- ~/.config/nvim/lua/plugins/lazydev.lua
return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                -- Carrega tipos do runtime e da biblioteca UV (vim.uv)
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}
