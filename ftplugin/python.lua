-- Carrega os ajustes nativos antes das opções e atalhos locais.
vim.cmd.runtime("ftplugin/python.vim")
require("config.python").attach(0)
