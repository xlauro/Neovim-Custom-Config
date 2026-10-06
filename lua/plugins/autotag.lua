-- ~/.config/nvim/lua/plugins/autotag.lua
return {
    {
        "windwp/nvim-ts-autotag",
        event = { "BufReadPre", "BufNewFile" },
        opts = {},
    },
}
