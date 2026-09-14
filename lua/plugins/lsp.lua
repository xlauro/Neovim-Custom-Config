-- ~/.config/nvim/lua/plugins/lsp.lua
return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            -- Atalhos universais ativados para C, C++, Rust, Zig e Lua
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
                    end

                    -- Navegação Universal
                    map("gd", vim.lsp.buf.definition, "Ir para definição")
                    map("gD", vim.lsp.buf.declaration, "Ir para declaração")
                    map("gr", vim.lsp.buf.references, "Listar referências")
                    map("gi", vim.lsp.buf.implementation, "Ir para implementação")
                    map("K", vim.lsp.buf.hover, "Ver documentação (Hover)")

                    -- Ações sob o prefixo <leader>c (reconhecido pelo which-key)
                    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("<leader>cr", vim.lsp.buf.rename, "Renomear símbolo")
                    map("<leader>cd", vim.diagnostic.open_float, "Ver erro da linha")
                    map("<leader>cf", function()
                        require("conform").format({ lsp_format = "fallback" })
                    end, "Formatar arquivo")

                    -- Navegação entre erros
                    map("[d", vim.diagnostic.goto_prev, "Diagnóstico anterior")
                    map("]d", vim.diagnostic.goto_next, "Próximo diagnóstico")
                end,
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            require("mason").setup({
                ui = { border = "rounded" },
            })

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",        -- Lua
                    "clangd",        -- C e C++
                    "rust_analyzer", -- Rust
                    "zls",           -- Zig
                },
                automatic_installation = true,
                handlers = {
                    -- Handler genérico para qualquer servidor instalado
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,

                    -- Ajustes específicos para C/C++
                    ["clangd"] = function()
                        require("lspconfig").clangd.setup({
                            capabilities = capabilities,
                            cmd = {
                                "clangd",
                                "--background-index",
                                "--clang-tidy",
                                "--completion-style=detailed",
                                "--header-insertion=iwyu",
                            },
                        })
                    end,
                    vim.diagnostic.config({
                        virtual_text = true,
                        signs = {
                            text = {
                                [vim.diagnostic.severity.ERROR] = " ",
                                [vim.diagnostic.severity.WARN] = " ",
                                [vim.diagnostic.severity.HINT] = "󰌵",
                                [vim.diagnostic.severity.INFO] = " ",
                            },
                        },
                        float = { border = "rounded" },
                    }),
                    -- Ajustes específicos para Rust
                    ["rust_analyzer"] = function()
                        require("lspconfig").rust_analyzer.setup({
                            capabilities = capabilities,
                            settings = {
                                ["rust-analyzer"] = {
                                    checkOnSave = { command = "clippy" },
                                    cargo = { allFeatures = true },
                                },
                            },
                        })
                    end,

                    -- Ajustes específicos para Zig
                    ["zls"] = function()
                        require("lspconfig").zls.setup({
                            capabilities = capabilities,
                            settings = {
                                zls = {
                                    enable_build_on_save = true,
                                },
                            },
                        })
                    end,

                    -- Ajustes para Lua
                    ["lua_ls"] = function()
                        require("lspconfig").lua_ls.setup({
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = { globals = { "vim" } },
                                    workspace = { checkThirdParty = false },
                                    telemetry = { enable = false },
                                },
                            },
                        })
                    end,
                },
            })
        end,
    },
}
