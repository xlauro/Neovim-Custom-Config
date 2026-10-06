-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
    {
        "maxmx03/fluoromachine.nvim",
        lazy = false,
        priority = 1000, -- Carrega antes dos outros plugins
        config = function()
            local fm = require("fluoromachine")
            fm.setup({
                glow = true,
                theme = "fluoromachine", -- Synthwave '84 aesthetic com efeito neon glow
                transparent = false,
            })
            vim.cmd.colorscheme("fluoromachine")
        end,
    },
}
