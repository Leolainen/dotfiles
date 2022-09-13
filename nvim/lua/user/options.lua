local options = {
  backup = false, -- creates a backup file
  background = 'dark',
  clipboard = 'unnamedplus', -- allows neovim to access the system clipboard
  cmdheight = 2, -- more space in the neovim command line for displaying messages
  completeopt = {
    'menuone',
    'noselect',
  }, -- mostly just for cmp
  conceallevel = 0, -- so that `` is visible in markdown files
  fileencoding = 'utf-8', -- the encoding written to a file
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  mouse = 'a', -- allow the mouse to be used in neovim
  pumheight = 10, -- pop up menu height
  showmode = true, -- show mode like -- INSERT --
  showtabline = 2, -- always show tabs
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go to the right of current window
  swapfile = false, -- disable creates a swapfile
  timeoutlen = 400, -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true, -- enable persistent undo
  updatetime = 300, -- faster completion (4000ms default)
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true, -- convert tabs to spaces
  shiftwidth = 2, -- the number of spaces inserted for each indentation
  tabstop = 2, -- insert 2 spaces for a tab
  softtabstop = 2, -- insert 2 spaces for a tab
  cursorline = true, -- highlight the current line
  number = true, -- set numbered lines
  relativenumber = true, -- set relative numbered lines
  numberwidth = 4, -- set number column width to 2 {default 4}
  signcolumn = 'yes', -- always show the sign column, otherwise it would shift the text each time
  wrap = false, -- display lines as one long line
  scrolloff = 8, -- is one of my fav
  sidescrolloff = 8,
  textwidth = 90,
  -- guifont = "monospace:h17",               -- the font used in graphical neovim applications
}

vim.opt.shortmess:append('c')

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- set colorscheme to aylin
vim.cmd([[colorscheme aylin]])

-- consider words with dashes as one word "one-word"
vim.cmd([[set iskeyword+=-]])

-- enable true colors
vim.cmd([[
	if (has("termguicolors"))
		set termguicolors
	endif
]])

-- toggle absolute line numbers during Insert mode
vim.cmd([[
	augroup numbertoggle
		autocmd!
		autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
		autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
	augroup END
]])

-- Disable automatic comment insertion when pressing o
vim.cmd([[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]])

-- Format and write after save asynchronously:
vim.cmd([[augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost * FormatWrite
  augroup END
]])