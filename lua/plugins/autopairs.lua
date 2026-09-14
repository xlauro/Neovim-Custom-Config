-- ~/.config/nvim/lua/plugins/autopairs.lua
return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            check_ts = true, -- Usa o Treesitter para evitar pares duplicados dentro de strings/comentários
            enable_check_bracket_line = false,
            fast_wrap = {},
        },
        config = function(_, opts)
            local npairs = require("nvim-autopairs")
            npairs.setup(opts)

            -- Integração com nvim-cmp: adiciona () ao autocompletar funções/métodos
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },
}
