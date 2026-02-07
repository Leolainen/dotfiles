-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-----------
-- NORMAL
-----------

-- remap [ and ] keys to å and ¨ to match american keyboard layout
map("n", "ö", "[", { remap = true })
map("n", "å", "]", { remap = true })
-- map("n", "¨", "]", { remap = true })
-- map("n", "ä", "]", { remap = true })

-- add your own keymapping
-- map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save", silent = true })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save", silent = true })
map("n", "ﬁ", "$", { desc = "Jump to end", silent = true })
map("n", "˛", "^", { desc = "Jump to start", silent = true })

-- clone line to line below/above
map("n", "<C-√>", "yyp", { desc = "Clone line down", silent = true })
map("n", "<C-ª>", "yyP", { desc = "Clone line up", silent = true })

-- Navigate tabs & buffers
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer", silent = true })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer", silent = true })

map("n", "<CR>", ":noh<CR><CR>", { desc = "Remove highlights", silent = true })
map("n", "<leader>h", ":noh<CR><CR>", { desc = "Remove highlights", silent = true })

-- Resize with arrows
map("n", "<Up>", ":resize -2<CR>", { desc = "Decrease vertical window size", silent = true })
map("n", "<Down>", ":resize +2<CR>", { desc = "Increase vertical window size", silent = true })
map("n", "<Left>", ":vertical resize -2<CR>", { desc = "Decrease horizontal window size", silent = true })
map("n", "<Right>", ":vertical resize +2<CR>", { desc = "Increase horizontal window size", silent = true })

map("n", ",", ";", { desc = "Repeat last search forward", silent = true })
map("n", ";", ",", { desc = "Repeat last search backwards", silent = true })

-- Always send contents of a `x` command to the black hole register.
-- Don't yank on delete char
map("n", "x", '"_x', { desc = "Delete char without yanking", silent = true })
map("n", "X", '"_X', { desc = "Delete previous char without yanking", silent = true })

-- quick console log word under cursor in JS
map("n", "cl", 'viwyoconsole.log("<C-R>% ~ line: <C-R>=line(".")+1<CR> ~ <C-R>0", <C-R>0);<Esc>h', {
    desc = "quick console log word under cursor in JS",
    silent = true,
})

-- Show hover
map("n", "gh", "<cmd>lua vim.lsp.buf.hover()<cr>", {
    desc = "Open hover window",
})

-- move "marks" key from ` to ¨ for convenience on swedish keyboard
map("n", "ä", "`", { desc = "marks" })

-- toggle capital or uncapitalized char & stay on same char
map("n", "§", "~h", { desc = "Capitalize character under cursor" })

map({ "n", "i" }, "<C-BS>", "<Del>", { desc = "Remove last char", silent = true })

-----------
-- INSERT
-----------
map("i", "˛", "<C-o>h", { desc = "Move cursor left in insert mode", silent = true })
map("i", "√", "<C-o>j", { desc = "Move cursor down in insert mode", silent = true })
map("i", "ª", "<C-o>k", { desc = "Move cursor up in insert mode", silent = true })
map("i", "ﬁ", "<C-o>l", { desc = "Move cursor right in insert mode", silent = true })

map("i", "jj", "<esc>", { desc = "Escape insert mode" })

-----------
-- VISUAL
-----------
-- don't overwrite yanked lines with overwritten lines
map("v", "p", '"_dP', { desc = "Overwrites without yanking line" })

-- Stay in indent mode
map("v", "<", "<gv", { desc = "Indent left without leaving visual mode" })
map("v", ">", ">gv", { desc = "Indent right without leaving visual mode" })

-- Move text up and down - Fixed with plugin
-- map("v", '√', ':m .+1<CR>==', { desc = "Move "})
-- map("v", 'ª', ':m .-2<CR>==', { desc = ""})

map("v", "cl", 'y<esc>oconsole.log("<C-R>% ~ line: <C-R>=line(".")+1<CR> ~ <C-R>0", <C-R>0);<Esc>h', {
    desc = "quick console log selection in JS",
})

-- Copilot keymaps
-- map("v", "<C-h>", "<Plug>(copilot-dismiss)", { desc = "" })
-- map("v", "<C-j>", "<Plug>(copilot-next)", { desc = "" })
-- map("v", "<C-k>", "<Plug>(copilot-previous)", { desc = "" })
-- map("v", "<C-l>", "<Plug>(copilot-accept-line)", { desc = "" })
-- map("v", "<C-L>", "<Plug>(copilot-accept-word)", { desc = "" })
-- map("v", "<C-J>", "<Plug>(copilot-suggest)", { desc = "" })
