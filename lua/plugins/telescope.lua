-- ~/.config/nvim/lua/plugins/telescope.lua
return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        keys = {
            { "<leader><leader>", "<cmd>Telescope find_files<cr>",  desc = "Buscar arquivos por nome" },
            { "<leader>fg",       "<cmd>Telescope live_grep<cr>",   desc = "Buscar texto no projeto (Grep)" },
            { "<leader>fw",       "<cmd>Telescope grep_string<cr>", desc = "Buscar palavra sob o cursor" },
            { "<leader>fb",       "<cmd>Telescope buffers<cr>",     desc = "Listar buffers abertos" },
            { "<leader>fd",       "<cmd>Telescope diagnostics<cr>", desc = "Buscar erros/diagnósticos (LSP)" },
            { "<leader>fh",       "<cmd>Telescope help_tags<cr>",   desc = "Buscar documentação/help" },
        },
        opts = {
            defaults = {
                prompt_prefix = "   ",
                selection_caret = " ",
                path_display = { "truncate" },
                sorting_strategy = "ascending",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55,
                    },
                },
                -- Argumentos otimizados para o ripgrep
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",      -- minúsculas = busca case-insensitive; maiúsculas = case-sensitive
                    "--trim",            -- remove espaços em branco extras na pré-visualização
                    "--glob=!**/.git/*", -- ignora a pasta de metadados do Git


                },
            },
        },
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            pcall(telescope.load_extension, "fzf")
        end,
    },
}
