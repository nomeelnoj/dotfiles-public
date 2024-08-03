vim.filetype.add({
  extension = {
    ["sh.tmpl"] = "bash",
    ["sh.tpl"] = "bash",
  },
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.zshrc_secure",
  command = "set filetype=secure | set ft=bash",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "COMMIT_EDITMSG",
  command = "set filetype=gitcommit",
})
