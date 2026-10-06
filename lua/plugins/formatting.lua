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
                rust = { "rustfmt" },
                zig = { "zigfmt" },
                zon = { "zigfmt" },
                python = { "ruff_organize_imports", "ruff_format" },
                go = { "goimports", "gofumpt" },
                javascript = { "prettierd", "prettier", "biome", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
                typescript = { "prettierd", "prettier", "biome", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
                json = { "prettierd", "prettier", "biome", stop_after_first = true },
                jsonc = { "prettierd", "prettier", "biome", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                scss = { "prettierd", "prettier", stop_after_first = true },
                markdown = { "prettierd", "prettier", stop_after_first = true },
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
