-- ~/.config/nvim/lua/plugins/which-key.lua
return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix", -- Janela flutuante moderna
            delay = 200, -- Tempo de resposta em ms
            spec = {
                { "<leader>b", group = "Buffers", icon = "󰈔" },
                { "<leader>c", group = "Código / LSP / Build", icon = "" },
                { "<leader>d", group = "Debug (DAP)", icon = "" },
                { "<leader>f", group = "Busca / Terminal", icon = "" },
                { "<leader>g", group = "Git", icon = "" },
                { "<leader>e", desc = "Alternar Neo-tree", icon = "󰙅" },
                { "<leader>o", desc = "Focar na Neo-tree", icon = "󰙅" },
                { "<leader><leader>", desc = "Buscar arquivos (Fuzzy)", icon = " " },
            },
        },
    },
}
