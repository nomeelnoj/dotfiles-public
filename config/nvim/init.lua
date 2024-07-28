vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.zshrc_secure",
  command = "set filetype=secure",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "COMMIT_EDITMSG",
  command = "set filetype=gitcommit",
})

vim.g.mapleader = " "

-- bootstrap lazy.nvim
require("config.lazy")
require("config.autocmds")
require("config.keymaps")
require("config.filetype")

-- Set line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Minimum number of screen lines above/below the cursor
vim.opt.scrolloff = 10

-- Show the line and column number of the cursor position
vim.opt.ruler = true

-- Set the width of the tab character
vim.opt.tabstop = 2

-- Set the width of the soft tab character
vim.opt.shiftwidth = 2

-- Set number of spaces for a tab
vim.opt.softtabstop = 2

-- Convert tabs to spaces
vim.opt.expandtab = true

-- Vertical split right
vim.opt.splitright = true

-- nvim-tree
-- disable netrw at the very start of your init.lua
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- undofile so you can undo after closing / saving a file
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.opt.undofile = true

-- Set Paste mode for easier pasting from external sources
-- vim.opt.paste = true

-- Show (partial) command in the last line of the screen
-- vim.opt.showcmd = true

-- When a bracket is inserted, briefly jump to the matching one
-- vim.opt.showmatch = true

-- Configuring the statusline. For appending, you have to reconstruct it since there's no direct append method in Lua.
-- Assuming 'statusline' is already set to something, and you want to add to it:
-- Note: Direct manipulation like this might not directly translate. You'll likely need to adjust the statusline setup more comprehensively in Lua.
-- vim.opt.statusline = vim.opt.statusline:get() .. "%#warningmsg#" -- switch to warningmsg color
-- vim.opt.statusline = vim.opt.statusline:get() .. "%*" -- back to normal color

-- Allows backspace to delete over line breaks, indentation, and the start of insert action
-- vim.opt.backspace = { "indent", "eol", "start" }
--
--     local au = vim.api.nvim_create_autocmd
--

-- Disable mouse mode
-- TODO: This shouldn't be disabled but clipboard isn't working
vim.opt.mouse = ''

-- Format terraform on save

-- require'lspconfig'.terraformls.setup{}
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = {"*.tf", "*.tfvars"},
--   callback = function()
--     vim.lsp.buf.format()
--   end,
-- })

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.tf",
--   callback = function()
--     if vim.fn.filereadable(vim.fn.expand('%:p')) == 0 then
--       vim.cmd('write')
--     end
--     vim.lsp.buf.format()
--   end,
-- })

-- vim.lsp.set_log_level("debug")
