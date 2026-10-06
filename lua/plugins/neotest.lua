-- ~/.config/nvim/lua/plugins/neotest.lua
return {
    {
        "nvim-neotest/neotest",
        keys = {
            { "<leader>tr", desc = "Rodar teste mais próximo" },
            { "<leader>tt", desc = "Rodar teste mais próximo" },
            { "<leader>tf", desc = "Rodar todos os testes do arquivo" },
            { "<leader>ts", desc = "Alternar painel em árvore (Test Summary)" },
            { "<leader>to", desc = "Ver saída do teste (Output)" },
            { "<leader>tO", desc = "Alternar painel de saída dos testes" },
            { "<leader>td", desc = "Depurar teste mais próximo (DAP)" },
            { "<leader>tS", desc = "Interromper execução dos testes" },
            { "<leader>pt", desc = "Python: Rodar teste mais próximo" },
            { "<leader>pf", desc = "Python: Rodar testes do arquivo" },
        },
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            "mfussenegger/nvim-dap",
        },
        config = function()
            local neotest = require("neotest")

            local function get_python_interpreter()
                local cwd = vim.fn.getcwd()
                if vim.fn.filereadable(cwd .. "/.venv/bin/python") == 1 then
                    return cwd .. "/.venv/bin/python"
                end
                local venv = os.getenv("VIRTUAL_ENV")
                if venv and vim.fn.filereadable(venv .. "/bin/python") == 1 then
                    return venv .. "/bin/python"
                end
                return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
            end

            neotest.setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        runner = "pytest",
                        python = get_python_interpreter,
                        pytest_discover_instances = true,
                    }),
                },
                status = {
                    virtual_text = true,
                    signs = true,
                },
                output = {
                    open_on_run = "short",
                },
                quickfix = {
                    open = function()
                        vim.cmd("copen")
                    end,
                },
            })

            -- Atalhos dedicados sob o grupo <leader>t (Testes)
            vim.keymap.set("n", "<leader>tr", function() neotest.run.run() end,
                { desc = "Rodar teste mais próximo" })
            vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end,
                { desc = "Rodar teste mais próximo" })
            vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end,
                { desc = "Rodar todos os testes do arquivo" })
            vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end,
                { desc = "Alternar painel em árvore (Test Summary)" })
            vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true, auto_close = true }) end,
                { desc = "Ver saída do teste (Output)" })
            vim.keymap.set("n", "<leader>tO", function() neotest.output_panel.toggle() end,
                { desc = "Alternar painel de saída dos testes" })
            vim.keymap.set("n", "<leader>td", function() neotest.run.run({ strategy = "dap" }) end,
                { desc = "Depurar teste mais próximo (DAP)" })
            vim.keymap.set("n", "<leader>tS", function() neotest.run.stop() end,
                { desc = "Interromper execução dos testes" })
        end,
    },
}
