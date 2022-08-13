local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap('', '<Space>', '<Nop>', { noremap = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- space + S + R to replace all occurences of the word under the cursor
keymap('n', '<leader>sr', ':%s/<C-R><C-W>/', opts)

-- quickly yank word under cursor
keymap('n', '<leader>y', 'viwy', opts)
keymap('n', '<leader>p', 'viwp', opts)

-- clone line to line below/above
keymap('n', '<C-√>', 'yyp', opts)
keymap('n', '<C-ª>', 'yyP', opts)

-- make sure n will search forward regardless if searching with ? or #
keymap(
  'n',
  'n',
  "(v:searchforward ? 'n' : 'N')",
  { noremap = true, silent = true, expr = true }
)
keymap(
  'n',
  'N',
  "(v:searchforward ? 'N' : 'n')",
  { noremap = true, silent = true, expr = true }
)

-- remove higlights
keymap('n', '<CR>', ':noh<CR><CR>', opts)

-- jump to  first or last column of a line
keymap('n', '<leader>h', '0', opts)
keymap('n', '<leader>l', '$', opts)

-- Resize with arrows
keymap('n', '<Up>', ':resize -2<CR>', opts)
keymap('n', '<Down>', ':resize +2<CR>', opts)
keymap('n', '<Left>', ':vertical resize -2<CR>', opts)
keymap('n', '<Right>', ':vertical resize +2<CR>', opts)

-- Navigate tabs & buffers
keymap('n', '<S-l>', ':bnext<CR>', opts) -- next buffer
keymap('n', '<S-h>', ':bprevious<CR>', opts) -- prev buffer
-- keymap('n', '<C-S-l>', ':tabnext<CR>', opts) -- next tab
-- keymap('n', '<C-S-h>', ':tabprevious<CR>', opts) -- prev tab

keymap('n', '<leader>qt', ':Bdelete<CR>', opts)
keymap('n', '<leader>qq', ':q!<CR>', opts)
keymap('n', '<leader>qw', ':w<CR>', opts)
keymap('n', '<leader>qA', ':qa!<CR>', opts)

-- Move text up and down
keymap('n', '√', ':m .+1<CR>==', opts)
keymap('n', 'ª', ':m .-2<CR>==', opts)

-- open recently closed files --
keymap('n', '<leader>T', ':tabe#<CR>', opts)
keymap('n', '<leader>X', ':sp#<CR>', opts)
keymap('n', '<leader>V', ':vsp#<CR>', opts)

-- easy yank & paste words --
keymap('n', '<leader>y', 'viwy', opts)
keymap('n', '<leader>p', 'viwp', opts)

-- swap places with , and ; --
keymap('n', ',', ';', opts)
keymap('n', ';', ',', opts)

-- Always send contents of a `x` command to the black hole register.
-- Don't yank on delete char
keymap('n', 'x', '"_x', opts)
keymap('n', 'X', '"_X', opts)

-- Insert --
-- Press jj to exit insert mode
keymap('i', 'jj', '<ESC>', opts)
keymap('i', 'jk', '<ESC>', opts)

-- Visual --
-- Stay in indent mode
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- Move text up and down
keymap('v', '√', ':m .+1<CR>==', opts)
keymap('v', 'ª', ':m .-2<CR>==', opts)

-- don't overwrite yanked lines with overwritten lines
keymap('v', 'p', '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap('x', 'J', ":move '>+1<CR>gv-gv", opts)
keymap('x', 'K', ":move '<-2<CR>gv-gv", opts)
keymap('x', '√', ":move '>+1<CR>gv-gv", opts)
keymap('x', 'ª', ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation (Set in toggleterm.lua)
-- keymap('t', '<C-h>', '<C-\\><C-N><C-w>h', term_opts)
-- keymap('t', '<C-j>', '<C-\\><C-N><C-w>j', term_opts)
-- keymap('t', '<C-k>', '<C-\\><C-N><C-w>k', term_opts)
-- keymap('t', '<C-l>', '<C-\\><C-N><C-w>l', term_opts)

-- NVIM-TREE --
keymap('n', '<leader>e', ':NvimTreeFindFile <CR>', opts)
keymap('v', '<leader>e', ':NvimTreeFindFile <CR>', opts)
--
-- -- TELESCOPE -- maps moved to whichkey.lua
-- keymap('n', '<leader>ff', ':Telescope find_files<CR>', opts)
-- keymap('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
-- keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
-- keymap('n', '<leader>fh', ':Telescope help_tags<CR>', opts)
-- keymap('n', '<leader>fd', ':Telescope git_status<CR>', opts)
-- keymap('n', '<leader>fp', ':Telescope projects<CR>', opts)
-- keymap('n', '<leader>fr', ':Telescope oldfiles<CR>', opts)
-- keymap('n', '<leader>fk', ':Telescope keymaps<CR>', opts)
-- keymap('n', '<leader>fc', ':Telescope commands<CR>', opts)
--
-- -- VS code-like keys
-- keymap('n', '<C-p>', ':Telescope find_files<CR>', opts)
-- keymap('i', '<C-p>', ':Telescope find_files<CR>', opts)
-- keymap('v', '<C-p>', ':Telescope find_files<CR>', opts)
--
-- keymap('n', '<C-f>', ':Telescope current_buffer_fuzzy_find<CR>', opts)
-- keymap('i', '<C-f>', ':Telescope current_buffer_fuzzy_find<CR>', opts)
-- keymap('v', '<C-f>', ':Telescope current_buffer_fuzzy_find<CR>', opts)

-- quick console log word under cursor in JS
keymap(
  'n',
  'cl',
  'viwyoconsole.log("<C-R>% ~ line: <C-R>=line(".")+1<CR> ~ <C-R>0", <C-R>0);<Esc>h',
  opts
)
keymap(
  'v',
  'cl',
  'y<esc>oconsole.log("<C-R>% ~ line: <C-R>=line(".")+1<CR> ~ <C-R>0", <C-R>0);<Esc>h',
  opts
)
-- keymap('n', '<C-ﬁ>', 'cl')
-- keymap('v', '<C-ﬁ>', 'cl')
