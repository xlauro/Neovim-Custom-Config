-- Carrega os ajustes nativos antes das opções e atalhos locais.
vim.cmd.runtime("ftplugin/zig.vim")
require("config.zig").attach(0)
