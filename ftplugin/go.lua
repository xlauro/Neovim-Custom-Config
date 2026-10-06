-- Carrega os ajustes nativos antes das opções e atalhos locais.
vim.cmd.runtime("ftplugin/go.vim")
require("config.go").attach(0)
