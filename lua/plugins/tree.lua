-- ~/.config/nvim/lua/plugins/tree.lua
return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        lazy = false, -- Impede o lazy-loading e carrega o plugin na inicialização
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle File Explorer" },
        },
        opts = {
            close_if_last_window = true,
            filesystem = {
                use_libuv_file_watcher = true,
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
                follow_current_file = {
                    enabled = true,
                },
            },
            event_handlers = {
                {
                    event = "file_renamed",
                    handler = function(args)
                        local changes = {
                            files = {
                                {
                                    oldUri = vim.uri_from_fname(args.source),
                                    newUri = vim.uri_from_fname(args.destination),
                                },
                            },
                        }
                        local clients = vim.lsp.get_clients()
                        for _, client in ipairs(clients) do
                            if client:supports_method("workspace/willRenameFiles") then
                                local resp = client.request_sync("workspace/willRenameFiles", changes, 2000, 0)
                                if resp and resp.result ~= nil then
                                    vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
                                end
                            end
                        end
                    end,
                },
                {
                    event = "file_moved",
                    handler = function(args)
                        local changes = {
                            files = {
                                {
                                    oldUri = vim.uri_from_fname(args.source),
                                    newUri = vim.uri_from_fname(args.destination),
                                },
                            },
                        }
                        local clients = vim.lsp.get_clients()
                        for _, client in ipairs(clients) do
                            if client:supports_method("workspace/willRenameFiles") then
                                local resp = client.request_sync("workspace/willRenameFiles", changes, 2000, 0)
                                if resp and resp.result ~= nil then
                                    vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
                                end
                            end
                        end
                    end,
                },
            },
        },
        init = function()
            vim.api.nvim_create_autocmd("VimEnter", {
                desc = "Abre o Neo-tree apenas se nenhum arquivo for passado",
                callback = function()
                    if vim.fn.argc() == 0 then
                        vim.schedule(function()
                            vim.cmd("Neotree show")
                        end)
                    end
                end,
            })
        end,
    },
}
