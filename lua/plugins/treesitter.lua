local languages = { "lua", "vim", "vimdoc", "c", "cpp", "rust", "zig" }

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local treesitter = require("nvim-treesitter")
            treesitter.setup()
            treesitter.install(languages)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = languages,
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end,
    },
}
