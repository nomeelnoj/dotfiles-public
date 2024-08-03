-- Jump to netrw or neotree
-- Check if Neotree is installed
local is_neotree_available = pcall(require, 'neo-tree')

if is_neotree_available then
  -- If Neotree is available, set keymap to focus Neotree
  vim.keymap.set("n", "<leader>pv", function()
    vim.cmd("Neotree focus")
  end)
else
  -- If Neotree is not available, set keymap to open netrw
  vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
end

-- open current dir for file in neotree
-- :Neotree dir=%:p:h


-- Allow moving selected text easily
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor in place when joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- Keep focused line in the middle when traversing vertically
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Keep focused line in the middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- When replacing text, the deleted text does not replace the paste register
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Yank text into system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Delete text without replacing the paste register
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Fuck capital Q
vim.keymap.set("n", "Q", "<nop>")

-- Open project in new tmux
-- not working and I dont have time rn to figure out why
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Format using lsp
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format()
end)

-- quickfix list navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext><CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- search and replace for word under cursor
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- set executable
vim.keymap.set("n", "<leader>x", "<cmd> !chmod +x %<CR>", { silent = true })

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

vim.api.nvim_set_keymap(
  'n',
  '<Leader>prov',
  ':lua tf_functions.provider()<CR>',
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
  { noremap = true, silent = false }
)

-- vim.api.nvim_create_user_command('Minify', function()
--   require('plugins.minify').minify()
-- end, {})
--
-- vim.api.nvim_create_user_command('LineMinify', function(params)
--   require('plugins.minify').line_minify(params.args:match("(%d+),(%d+)"))
-- end, { nargs = 1 })
--
-- vim.api.nvim_create_user_command('UnMinify', function()
--   require('plugins.minify').unminify()
-- end, {})
