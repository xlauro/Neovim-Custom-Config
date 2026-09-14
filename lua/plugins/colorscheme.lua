-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000, -- Carrega antes dos outros plugins
        config = function()
            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                transparent_background = false,
                integrations = {
                    treesitter = true,
                    native_lsp = { enabled = true },
                    neotree = true,
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
