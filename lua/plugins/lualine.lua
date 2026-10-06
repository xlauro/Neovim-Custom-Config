-- ~/.config/nvim/lua/plugins/lualine.lua
return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- Função para capturar os servidores LSP ativos no buffer atual
            local function lsp_clients()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if next(clients) == nil then
                    return "Sem LSP"
                end

                local names = {}
                for _, client in ipairs(clients) do
                    table.insert(names, client.name)
                end
                return "󰒋 " .. table.concat(names, ", ")
            end

            require("lualine").setup({
                options = {
                    theme = "fluoromachine",
                    globalstatus = true, -- Mantém uma única barra no rodapé mesmo com splits
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = { "neo-tree" }, -- Oculta a redundância na barra de arquivos
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                return str -- Exibe NORMAL, INSERT, VISUAL, TERMINAL, etc.
                            end,
                        },
                    },
                    lualine_b = {
                        { "branch", icon = "" },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                        },
                    },
                    lualine_c = {
                        {
                            "filename",
                            path = 1, -- Caminho relativo do arquivo
                            file_status = true,
                            symbols = {
                                modified = " ●",
                                readonly = " ",
                                unnamed = "[Sem Nome]",
                            },
                        },
                    },
                    lualine_x = {
                        {
                            "diagnostics",
                            sources = { "nvim_lsp" },
                            symbols = {
                                error = " ",
                                warn = " ",
                                info = " ",
                                hint = " ",
                            },
                        },
                        {
                            lsp_clients,
                            color = { gui = "bold" },
                        },
                        { "filetype" },
                    },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },
}
