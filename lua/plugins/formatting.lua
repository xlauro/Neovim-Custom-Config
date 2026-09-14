-- ~/.config/nvim/lua/plugins/formatting.lua
return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            -- Formatadores específicos por linguagem
            formatters_by_ft = {
                lua = { "stylua" },
            },
            -- Comportamento padrão para QUALQUER linguagem:
            default_format_opts = {
                lsp_format = "fallback",
            },
            format_on_save = {
                timeout_ms = 1000,
                lsp_format = "fallback",
            },
        },
    },
}
