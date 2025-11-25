local function get_args()
    local args = {}
    return vim.split(vim.fn.input("CMake args: ", table.concat(args, " ")), " ")
end

return {
    {
        "Civitasv/cmake-tools.nvim",
        opts = {
            cmake_build_directory = function()
                return "build/${variant:buildType}"
            end,
        },
        keys = {
            { "<leader>c", "", desc = "CMake" },
            { "<leader>cg", "<cmd>CMakeGenerate<cr>", desc = "Generate" },
            { "<leader>cb", "<cmd>CMakeBuild -j8<cr>", desc = "Build" },
            { "<leader>cr", "<cmd>CMakeRun<cr>", desc = "Run" },
            { "<leader>ci", "<cmd>CMakeInstall<cr>", desc = "Install" },
            { "<leader>ct", "<cmd>CMakeSelectBuildType<cr>", desc = "Select Build Type" },
            { "<leader>cT", "<cmd>CMakeSelectTarget<cr>", desc = "Select Build Target" },
            {
                "<leader>cG",
                function()
                    require("cmake-tools").generate({fargs = get_args()}, function() end) end,
                desc = "Generate with Args"
            },
            {
                "<leader>cB",
                function()
                    require("cmake-tools").build({fargs = get_args()}, function() end) end,
                desc = "Build with Args"
            },
        },
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "orjangj/neotest-ctest",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
        },
        config = function()
            local neotest_ns = vim.api.nvim_create_namespace("neotest")
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message = diagnostic.message:gsub("[\r\n\t%s]+", " ")
                        return message
                    end,
                },
            }, neotest_ns)

            require("neotest").setup({
                adapters = {
                    require("neotest-python")({}),
                    require("neotest-ctest").setup({}),
                }
            })
        end,
        keys = function()
            local neotest = require("neotest")

            return {
                { "<leader>t", "", desc = "Testing" },
                { "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, desc = "Run File" },
                { "<leader>tt", function() neotest.run.run() end, desc = "Run Nearest" },
                { "<leader>tw", function() neotest.run.run(vim.loop.cwd()) end, desc = "Run workspace" },
                { "<leader>tr",
                    function()
                        neotest.output.open({ short = true, auto_close = true })
                    end,
                    desc = "Results (short)",
                },
                { "<leader>tR",
                    function()
                        neotest.output.open({ enter = true})
                    end,
                    desc = "Results (full)",
                },
            }
        end,
    }
}
