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


-- Auto chmod bash files on save, but it happens every save, so <leader>x mapped instead in keymaps.lua
--autocmd("BufWritePost", {
--  pattern = "*.sh",
--  command = "!chmod +x %"
--})
