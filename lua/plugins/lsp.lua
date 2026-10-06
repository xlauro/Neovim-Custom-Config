-- ~/.config/nvim/lua/plugins/lsp.lua
return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "LspInfo", "Mason", "MasonInstall" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "b0o/SchemaStore.nvim",
        },
        config = function()
            -- Configuração visual de diagnósticos
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
            })

            require("config.auto_hover").setup()

            -- Atalhos universais ativados via LspAttach
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
                    end

                    local client = vim.lsp.get_client_by_id(ev.data.client_id)

                    -- Ativa Inlay Hints nativos do Neovim caso o servidor suporte
                    if client and client:supports_method("textDocument/inlayHint", ev.buf) then
                        vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
                    end

                    -- Navegação Universal
                    map("gd", vim.lsp.buf.definition, "Ir para definição")
                    map("gD", vim.lsp.buf.declaration, "Ir para declaração")
                    map("gr", vim.lsp.buf.references, "Listar referências")
                    map("gi", vim.lsp.buf.implementation, "Ir para implementação")
                    map("K", vim.lsp.buf.hover, "Ver documentação (Hover)")

                    if client and client:supports_method("textDocument/signatureHelp", ev.buf) then
                        vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, {
                            buffer = ev.buf,
                            desc = "Assinatura da função",
                        })
                    end

                    -- Navegação avançada para TypeScript (pula direto para o código-fonte .ts em vez do arquivo .d.ts)
                    map("gS", function()
                        local vtsls_client = vim.lsp.get_clients({ bufnr = ev.buf, name = "vtsls" })[1]
                        if vtsls_client then
                            local params = vim.lsp.util.make_position_params()
                            vtsls_client.request("workspace/executeCommand", {
                                command = "typescript.goToSourceDefinition",
                                arguments = { vim.api.nvim_buf_get_name(ev.buf), params.position },
                            }, function(err, result)
                                if result and #result > 0 then
                                    vim.lsp.util.jump_to_location(result[1], vtsls_client.offset_encoding)
                                else
                                    vim.lsp.buf.definition()
                                end
                            end)
                        else
                            vim.lsp.buf.definition()
                        end
                    end, "Ir para código-fonte original (Source Definition)")

                    -- Ações sob o prefixo <leader>c (reconhecido pelo which-key)
                    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("<leader>cr", vim.lsp.buf.rename, "Renomear símbolo")
                    map("<leader>cd", vim.diagnostic.open_float, "Ver erro da linha")
                    map("<leader>cD", vim.diagnostic.setloclist, "Listar erros do arquivo (Loclist)")
                    map("<leader>cf", function()
                        require("conform").format({ lsp_format = "fallback" })
                    end, "Formatar arquivo")

                    -- Refatorações dedicadas a TypeScript
                    map("<leader>co", function()
                        vim.lsp.buf.code_action({
                            context = { only = { "source.organizeImports" }, diagnostics = {} },
                            apply = true,
                        })
                    end, "Organizar imports (TypeScript)")

                    map("<leader>ci", function()
                        vim.lsp.buf.code_action({
                            context = { only = { "source.addMissingImports.ts" }, diagnostics = {} },
                            apply = true,
                        })
                    end, "Adicionar imports faltantes (TypeScript)")

                    map("<leader>cu", function()
                        vim.lsp.buf.code_action({
                            context = { only = { "source.removeUnused.ts" }, diagnostics = {} },
                            apply = true,
                        })
                    end, "Remover imports não utilizados (TypeScript)")

                    map("<leader>cs", "gS", "Ir para código-fonte original (Source Def)")

                    -- Alternar Inlay Hints sob demanda
                    map("<leader>ch", function()
                        local filter = { bufnr = ev.buf }
                        local current = vim.lsp.inlay_hint.is_enabled(filter)
                        vim.lsp.inlay_hint.enable(not current, filter)
                        vim.notify(
                            "Inlay Hints: " .. (not current and "Ativado" or "Desativado"),
                            vim.log.levels.INFO,
                            { title = "LSP" }
                        )
                    end, "Alternar dicas inline (Inlay Hints)")

                    -- Alternar Hover automático sob demanda
                    map("<leader>ck", function()
                        vim.g.disable_auto_hover = not vim.g.disable_auto_hover
                        vim.notify(
                            "Hover automático: " .. (vim.g.disable_auto_hover and "Desativado" or "Ativado"),
                            vim.log.levels.INFO,
                            { title = "LSP" }
                        )
                    end, "Alternar hover automático sob o cursor")

                    -- Navegação entre erros
                    map("[d", vim.diagnostic.goto_prev, "Diagnóstico anterior")
                    map("]d", vim.diagnostic.goto_next, "Próximo diagnóstico")
                end,
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            require("mason").setup({
                ui = { border = "rounded" },
            })

            -- Mason v2 ativa as configurações nativas do Neovim via vim.lsp.enable().
            vim.lsp.config("*", { capabilities = capabilities })

            vim.lsp.config("vtsls", {
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "javascript.jsx",
                    "typescript",
                    "typescriptreact",
                    "typescript.tsx",
                },
                settings = {
                    complete_function_calls = true,
                    vtsls = {
                        enableMoveToFileCodeAction = true,
                        autoUseWorkspaceTsdk = true,
                        experimental = {
                            maxInlayHintLength = 30,
                            completion = {
                                enableServerSideFuzzyMatch = true,
                            },
                        },
                    },
                    typescript = {
                        updateImportsOnFileMove = { enabled = "always" },
                        suggest = {
                            completeFunctionCalls = true,
                        },
                        inlayHints = {
                            parameterNames = { enabled = "literals" },
                            parameterTypes = { enabled = true },
                            variableTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                            enumMemberValues = { enabled = true },
                        },
                    },
                    javascript = {
                        updateImportsOnFileMove = { enabled = "always" },
                        suggest = {
                            completeFunctionCalls = true,
                        },
                        inlayHints = {
                            parameterNames = { enabled = "literals" },
                            parameterTypes = { enabled = true },
                            variableTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                            enumMemberValues = { enabled = true },
                        },
                    },
                },
            })

            vim.lsp.config("eslint", {
                settings = {
                    workingDirectories = { mode = "auto" },
                },
            })

            vim.lsp.config("jsonls", {
                before_init = function(_, config)
                    config.settings = config.settings or {}
                    config.settings.json = config.settings.json or {}
                    local ok, schemastore = pcall(require, "schemastore")
                    if ok then
                        config.settings.json.schemas = schemastore.json.schemas()
                    end
                end,
                settings = {
                    json = {
                        validate = { enable = true },
                    },
                },
            })

            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                },
            })

            vim.lsp.config("rust_analyzer", {
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy",
                        },
                        cargo = {
                            features = "all",
                            buildScripts = {
                                enable = true,
                            },
                        },
                        procMacro = {
                            enable = true,
                        },
                        inlayHints = {
                            bindingModeHints = { enable = false },
                            chainingHints = { enable = true },
                            closingBraceHints = { enable = true, minLines = 25 },
                            closureReturnTypeHints = { enable = "never" },
                            lifetimeElisionHints = { enable = "never" },
                            parameterHints = { enable = true },
                            typeHints = {
                                enable = true,
                                hideClosureInitialization = false,
                                hideNamedConstructor = false,
                            },
                        },
                    },
                },
            })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                            shadow = true,
                            nilness = true,
                            unusedwrite = true,
                            useany = true,
                        },
                        staticcheck = true,
                        gofumpt = true,
                        completeUnimported = true,
                        usePlaceholders = true,
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                        semanticTokens = true,
                    },
                },
            })

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",        -- Lua
                    "clangd",        -- C e C++
                    "rust_analyzer", -- Rust
                    "gopls",         -- Go (Google Language Server)
                    "vtsls",         -- TypeScript e JavaScript (VS Code engine)
                    "eslint",        -- Linter / formatador ESLint
                    "jsonls",        -- JSON Language Server com suporte a Schemas
                },
                automatic_enable = true,
            })
        end,
    },
}
