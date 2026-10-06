-- O Neovim atual já detecta .zon como Zig; atende também filetype=zon.
vim.cmd.runtime("ftplugin/zig.vim")
require("config.zig").attach(0)
