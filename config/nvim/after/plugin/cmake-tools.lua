local wk = require('which-key')
wk.register({
    c = {
        name = "+CMake",
        g = {":CMakeGenerate<CR>", "Generate" },
        b = {":CMakeBuild<CR>", "Build" },
        r = {":CMakeRun<CR>", "Run" },
        d = {":CMakeDebug<CR>", "Debug" },
        s = {":CMakeSelectBuildType<CR>", "Select Build Type" },
        i = {":CMakeInstall<CR>", "Install" },
    },
}, { prefix = "<leader>" })
