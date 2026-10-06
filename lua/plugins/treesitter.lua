-- ~/.config/nvim/lua/plugins/treesitter.lua
local languages = {
    "lua",
    "vim",
    "vimdoc",
    "c",
    "cpp",
    "rust",
    "zig",
    "python",
    "go",
    "gomod",
    "gowork",
    "gosum",
    "typescript",
    "javascript",
    "tsx",
    "jsdoc",
    "json",
    "html",
    "css",
}

local filetypes = {
    "lua",
    "vim",
    "vimdoc",
    "c",
    "cpp",
    "rust",
    "zig",
    "python",
    "go",
    "gomod",
    "gowork",
    "gosum",
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "html",
    "css",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "TSInstall", "TSBufEnable", "TSUpdate" },
        build = ":TSUpdate",
        config = function()
            local treesitter = require("nvim-treesitter")
            treesitter.setup()

            -- Associa jsonc ao parser json
            vim.treesitter.language.register("json", "jsonc")

            vim.api.nvim_create_autocmd("FileType", {
                pattern = filetypes,
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })

            if vim.tbl_contains(filetypes, vim.bo.filetype) then
                pcall(vim.treesitter.start)
            end
        end,
    },
}
