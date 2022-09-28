--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT


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
  numberwidth = 2, -- set number column width to 2 {default 4}
  signcolumn = 'yes', -- always show the sign column, otherwise it would shift the text each time
  wrap = false, -- display lines as one long line
  scrolloff = 10, -- is one of my fav
  sidescrolloff = 8,
  textwidth = 90,
  -- guifont = "monospace:h17",               -- the font used in graphical neovim applications
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- set colorscheme to aylin
-- vim.cmd([[colorscheme aylin]])

-- consider words with dashes as one word "one-word"
vim.cmd([[set iskeyword+=-]])

-- enable true colors
-- vim.cmd([[
--	if (has("termguicolors"))
--		set termguicolors
--	endif
--]])

-- toggle absolute line numbers during Insert mode
--vim.cmd([[
--	augroup numbertoggle
--		autocmd!
--		autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
--		autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
--	augroup END
--]])

-- Disable automatic comment insertion when pressing o
--vim.cmd(
-- [[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]
--)

-- Format and write after save asynchronously:
-- vim.cmd([[augroup FormatAutogroup
--     autocmd!
--     autocmd BufWritePost * FormatWrite
--   augroup END
-- ]])

-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "tokyonight"
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["ﬁ"] = "$"
lvim.keys.normal_mode["˛"] = "^"
-- clone line to line below/above
lvim.keys.normal_mode["<C-√>"] = "yyp"
lvim.keys.normal_mode["<C-ª>"] = "yyP"

-- Navigate tabs & buffers
lvim.keys.normal_mode['<S-l>'] = '<cmd>BufferLineCycleNext<cr>'
lvim.keys.normal_mode['<S-h>'] = '<cmd>BufferLineCyclePrev<cr>'
-- make sure n will search forward regardless if searching with ? or #
-- lvim.keys.normal_mode['n'] = "(v:searchforward ? 'n' : 'N')"
-- lvim.keys.normal_mode['N'] = "(v:searchforward ? 'N' : 'n')"
-- vim.keymap.set("n", "n", "(v:searchforward ? 'n' : 'N')")
-- vim.keymap.set("n", "N", "(v:searchforward ? 'N' : 'n')")

-- remove higlights
lvim.keys.normal_mode['<CR>'] = ':noh<CR><CR>'

-- Resize with arrows
lvim.keys.normal_mode['<Up>'] = ':resize -2<CR>'
lvim.keys.normal_mode['<Down>'] = ':resize +2<CR>'
lvim.keys.normal_mode['<Left>'] = ':vertical resize -2<CR>'
lvim.keys.normal_mode['<Right>'] = ':vertical resize +2<CR>'

-- Move text up and down
lvim.keys.normal_mode['√'] = ':m .+1<CR>=='
lvim.keys.normal_mode['ª'] = ':m .-2<CR>=='

-- swap places with , and ; --
lvim.keys.normal_mode[','] = ';'
lvim.keys.normal_mode[';'] = ','

-- Always send contents of a `x` command to the black hole register.
-- Don't yank on delete char
lvim.keys.normal_mode['x'] = '"_x'
lvim.keys.normal_mode['X'] = '"_X'

-- quick console log word under cursor in JS
lvim.keys.normal_mode['cl'] = 'viwyoconsole.log("<C-R>% ~ line: <C-R>=line(".")+1<CR> ~ <C-R>0", <C-R>0);<Esc>h'

-- Show hover
lvim.keys.normal_mode['gh'] = '<cmd>lua vim.lsp.buf.hover()<cr>'

-- Visual --
-- don't overwrite yanked lines with overwritten lines
lvim.keys.visual_mode['p'] = '"_dP'

-- Stay in indent mode
lvim.keys.visual_mode['<'] = '<gv'
lvim.keys.visual_mode['>'] = '>gv'

-- Move text up and down
lvim.keys.visual_mode['√'] = ':m .+1<CR>=='
lvim.keys.visual_mode['ª'] = ':m .-2<CR>=='

lvim.keys.visual_mode['cl'] = 'y<esc>oconsole.log("<C-R>% ~ line: <C-R>=line(".")+1<CR> ~ <C-R>0", <C-R>0);<Esc>h'

-- Visual Block --
-- Move text up and down
lvim.keys.visual_block_mode['J'] = ":move '>+1<CR>gv-gv"
lvim.keys.visual_block_mode['K'] = ":move '<-2<CR>gv-gv"
lvim.keys.visual_block_mode['√'] = ":move '>+1<CR>gv-gv"
lvim.keys.visual_block_mode['ª'] = ":move '<-2<CR>gv-gv"

-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
-- }

-- space + r to replace all occurences of the word under the cursor
lvim.builtin.which_key.mappings["r"] = { ':%s/<C-R><C-W>/', "replace all" }
lvim.builtin.which_key.mappings["y"] = {
  name = "+Yank",
  w = { "viwy", "word" },
  a = { "ggVGy", "all" },
  p = { "viw\"_dP", "Paste over word" }
}
lvim.builtin.which_key.mappings["g"]["S"] = { ":Git stage_buffer<CR>", "stage buffer" }
lvim.builtin.which_key.mappings["s"]["l"] = { ":Telescope resume<CR>", "Last search" }
lvim.builtin.which_key.mappings["g"]["q"] = { ":Gitsigns setqflist<CR>", "Quickfix hunks" }
lvim.builtin.which_key.mappings["s"]["T"] = { ":lua require('telescope.builtin').live_grep{ cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1] }<CR>",
  "text from root" }
-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- -- make sure server will always be installed even if the server is in skipped_servers list
-- lvim.lsp.installer.setup.ensure_installed = {
--     "sumeko_lua",
--     "jsonls",
-- }
-- -- change UI setting of `LspInstallInfo`
-- -- see <https://github.com/williamboman/nvim-lsp-installer#default-configuration>
-- lvim.lsp.installer.setup.ui.check_outdated_servers_on_open = false
-- lvim.lsp.installer.setup.ui.border = "rounded"
-- lvim.lsp.installer.setup.ui.keymaps = {
--     uninstall_server = "d",
--     toggle_server_expand = "o",
-- }

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "tsserver" })

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- vim.tbl_map(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  --   { command = "black", filetypes = { "python" } },
  --   { command = "isort", filetypes = { "python" } },
  {
    --     -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
    command = "prettier",
    --     ---@usage arguments to pass to the formatter
    --     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
    -- extra_args = { "--print-with", "100" },
    --     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less", "html",
      "json", "jsonc", "yaml", "markdown", "graphql", "handlebars" },
  },
}

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   --   { command = "flake8", filetypes = { "python" } },
--   --   {
--   --     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--   --     command = "shellcheck",
--   --     ---@usage arguments to pass to the formatter
--   --     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--   --     extra_args = { "--severity", "warning" },
--   --   },
--   --   {
--   --     command = "codespell",
--   --     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--   --     filetypes = { "javascript", "python" },
--   --   },
--   {
--     command = "eslint_d",
--     filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
--     args = {
--       '--config-precedence',
--       'prefer-file',
--       '--single-quote',
--       '--no-bracket-spacing',
--       '--prose-wrap',
--       'always',
--       '--arrow-parens',
--       'always',
--       '--trailing-comma',
--       'all',
--       '--no-semi',
--       '--end-of-line',
--       'lf',
--       '--print-width',
--       vim.bo.textwidth <= 80 and 80 or vim.bo.textwidth,
--       '--stdin-filepath',
--       vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
--     },
--     stdin = true,
--   }
-- }

require("lvim.lsp.manager").setup("eslint")

-- Additional Plugins
lvim.plugins = {
  {
    'AhmedAbdulrahman/aylin.vim',
  },
  {
    'mg979/vim-visual-multi',
    -- branch = 'master',
    config = "require('plugins.vim-visual-multi')",
  },
  {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup()
    end
  },
  {
    'wfxr/minimap.vim',
    -- config = "require('plugins.minimap')",
  },
  {
    "kevinhwang91/nvim-bqf",
    event = { "BufRead", "BufNew" },
    config = function()
      require("bqf").setup({
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
        },
        func_map = {
          vsplit = "",
          ptogglemode = "z,",
          stoggleup = "",
        },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
          },
        },
      })
    end,
  },
  { "folke/tokyonight.nvim" },
  { 'akinsho/git-conflict.nvim', tag = "*", config = function()
    require('git-conflict').setup({
      {
        disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
        highlights = { -- They must have background color, otherwise the default color will be used
          incoming = 'DiffText',
          current = 'DiffAdd',
        }
      }
    })
  end },
  {
    "ggandor/leap.nvim",
    event = "BufRead",
    config = "require('leap').set_default_keymaps()"
  },
  {
    "gen740/SmoothCursor.nvim",
    config = function()
      require("smoothcursor").setup({
        autostart = true,
        cursor = "", -- cursor shape (need nerd font)
        intervals = 35, -- tick interval
        linehl = nil, -- highlight sub-cursor line like 'cursorline', "CursorLine" recommended
        type = "default", -- define cursor movement calculate function, "default" or "exp" (exponential).
        fancy = {
          enable = true, -- enable fancy mode
          head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
          body = {
            -- { cursor = "█", texthl = "SmoothCursorAqua" },
            -- { cursor = "▉", texthl = "SmoothCursorAqua" },
            -- { cursor = "▊", texthl = "SmoothCursorAqua" },
            -- { cursor = "▋", texthl = "SmoothCursorBlue" },
            -- { cursor = "▌", texthl = "SmoothCursorBlue" },
            -- { cursor = "▍", texthl = "SmoothCursorPurple" },
            -- { cursor = "▎", texthl = "SmoothCursorPurple" },

            { cursor = "▓", texthl = "SmoothCursorAqua" },
            { cursor = "▓", texthl = "SmoothCursorAqua" },
            { cursor = "▒", texthl = "SmoothCursorAqua" },
            { cursor = "▒", texthl = "SmoothCursorBlue" },
            { cursor = "▒", texthl = "SmoothCursorBlue" },
            { cursor = "░", texthl = "SmoothCursorPurple" },
            { cursor = "░", texthl = "SmoothCursorPurple" },

            -- { cursor = "▓", texthl = "SmoothCursorAqua" },
            -- { cursor = "▚", texthl = "SmoothCursorAqua" },
            -- { cursor = "▞", texthl = "SmoothCursorAqua" },
            -- { cursor = "▝", texthl = "SmoothCursorBlue" },
            -- { cursor = "▗", texthl = "SmoothCursorBlue" },
            -- { cursor = "▘", texthl = "SmoothCursorPurple" },
            -- { cursor = "▖", texthl = "SmoothCursorPurple" },

            -- { cursor = "", texthl = "SmoothCursorAqua" },
            -- { cursor = "", texthl = "SmoothCursorAqua" },
            -- { cursor = "●", texthl = "SmoothCursorBlue" },
            -- { cursor = "●", texthl = "SmoothCursorBlue" },
            -- { cursor = "•", texthl = "SmoothCursorPurple" },
            -- { cursor = ".", texthl = "SmoothCursorPurple" },
            -- { cursor = ".", texthl = "SmoothCursorPurple" },
          },
          tail = { cursor = nil, texthl = "SmoothCursor" }
        },
        priority = 10, -- set marker priority
        speed = 45, -- max is 100 to stick to your current position
        texthl = "SmoothCursor", -- highlight group, default is { bg = nil, fg = "#FFD400" }
        threshold = 3,
        timeout = 3000,
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    -- config = "require('treesitter-context).setup()"
  }
  -- { 'RRethy/vim-illuminate' },
  -- {
  --   'levouh/tint.nvim',
  --   config = "require('tint').setup()"
  -- }
  -- {
  --   "folke/trouble.nvim",
  --   cmd = "TroubleToggle",
  -- },
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.json", "*.jsonc" },
--   -- enable wrap mode for json files only
--   command = "setlocal wrap",
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })

-- PLUGIN OVERRIDES --
-- open terminal
lvim.builtin.terminal.open_mapping = "<C-SPACE>"

-- prevent nvimtree from updating tree when inspecting other buffers
-- lvim.builtin.nvimtree.setup.update_focused_file.enable = false
-- lvim.builtin.nvimtree.setup.update_focused_file.update_cwd = false
lvim.builtin.nvimtree.setup.prefer_startup_root = true -- if update_focused_file is enabled

lvim.builtin.nvimtree.setup.update_cwd = false
lvim.builtin.nvimtree.setup.update_focused_file = {
  enable = false,
  update_root = false,
  ignore_list = {},
}
lvim.builtin.nvimtree.setup.hijack_directories = {
  enable = false,
  auto_open = false,
}
lvim.builtin.nvimtree.setup.actions.change_dir.enable = false
-- lvim.builtin.telescope.mappings.i["<C-j>"]["1"] = "move_selection_previous"
-- lvim.builtin.telescope.mappings.i["<C-k>"]["1"] = "move_selection_next"
-- lvim.builtin.telescope.mappings.i["<C-n>"]["1"] = "cycle_history_next"
-- lvim.builtin.telescope.mappings.i["<C-p>"]["1"] = "cycle_history_prev"

lvim.transparent_window = true
