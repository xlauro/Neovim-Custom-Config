-- ~/.config/nvim/lua/plugins/completion.lua
return {
    {
        "hrsh7th/nvim-cmp",
        event = { "InsertEnter", "BufReadPre", "BufNewFile" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            require("luasnip.loaders.from_lua").lazy_load({
                paths = { vim.fn.stdpath("config") .. "/snippets" },
            })

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                preselect = cmp.PreselectMode.None,
                -- Sugestões automáticas ao digitar
                completion = {
                    autocomplete = {
                        cmp.TriggerEvent.TextChanged,
                    },
                    completeopt = "menu,menuone,noselect",
                    keyword_length = 1,
                },
                -- Equilíbrio ideal entre resposta rápida e estabilidade com LSPs
                performance = {
                    debounce = 60,
                    throttle = 30,
                    fetching_timeout = 1500,
                },
                -- Prévia em texto cinza (inline ghost text) enquanto digita
                experimental = {
                    ghost_text = true,
                },
                view = {
                    docs = { auto_open = true },
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    -- Aceitar a sugestão com Tab
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.confirm({ select = true })
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    -- Aceitar sugestão com Enter (apenas se item estiver explicitamente selecionado)
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),

                    -- Expandir snippets e percorrer argumentos sem alterar o Tab
                    ["<C-l>"] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<C-h>"] = cmp.mapping(function(fallback)
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    -- Recusar / fechar o autocompletion com a seta para a esquerda
                    ["<Left>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.abort()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    -- Navegação na lista de sugestões
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

                    -- Scroll na documentação
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    -- Atalho manual mantido sob demanda
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = "lazydev", group_index = 0 }, -- integra tipagem lua do Neovim
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip", priority = 750 },
                    { name = "path", priority = 500 },
                }, {
                    {
                        name = "buffer",
                        priority = 250,
                        keyword_length = 2,
                        option = {
                            get_bufnrs = function()
                                return vim.api.nvim_list_bufs()
                            end,
                        },
                    },
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "...",
                    }),
                },
            })

            -- Garante que o nvim-cmp seja sempre notificado em qualquer edição no Insert Mode
            local group = vim.api.nvim_create_augroup("UserCmpAutoTrigger", { clear = true })
            vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
                group = group,
                callback = function()
                    if cmp.core and vim.api.nvim_get_mode().mode == "i" then
                        cmp.core:on_change("TextChanged")
                    end
                end,
            })
        end,
    },
}
