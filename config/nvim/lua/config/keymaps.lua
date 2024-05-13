-- AWS Functions
-- aws_functions = require('functions.aws')

-- Terraform Functions
tf_functions = require('functions.tf')

-- Setting a keymap for inserting the data block for sso roles
vim.api.nvim_set_keymap(
  'n',
  '<Leader>sso',
  ':lua tf_functions.ssodata()<CR>',
  {
    noremap = true,
    silent = true
  }
)

vim.api.nvim_exec([[
  function! SourceDirectory(directory, extension)
    let l:directory = a:directory == '' ? expane('%:p:h') : a:directory
    for filename in split(glob(l:directory . './*.' . a:extension), '\n')
      if a:extension == 'lua'
        execute 'luafile ' . filename
      else
        execute 'source ' . filename
      endif
    endfor
  endfunction
]], false)

vim.keymap.set(
  'n',
  '<Leader><Leader>sl',
  ':call SourceDirectory("~/.config/nvim/lua/snippets", "lua")<CR>',
  { noremap = true, silent = true }
)

vim.keymap.set(
  'n',
  '<Leader><Leader>s',
  ':call SourceDirectory("", "")<CR>',
  { noremap = true, silent = true }
)

vim.keymap.set(
  'n',
  '<Leader>ff',
  ':Telescope find_files<CR>',
  { noremap = true, silent = false}
)