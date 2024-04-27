-- Add any additional keymaps here
local autocmd = vim.api.nvim_create_autocmd

autocmd("BufNewFile", {
        pattern = "*.sh",
        command = "call append(0, '#!/bin/bash')",
})

autocmd("BufNewFile", {
        pattern = "*.py",
        command = "call append(0, '#!/usr/bin/env python')",
})

autocmd("BufNewFile", {
        pattern = "*.tf",
        command = "set ft=terraform",
})

autocmd("BufWritePost", {
        pattern = "*.sh",
        command = "!chmod +x %"
})
