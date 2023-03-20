--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT


local options = {
    backup = false,            -- creates a backup file
    background = 'dark',
    clipboard = 'unnamedplus', -- allows neovim to access the system clipboard
    cmdheight = 2,             -- more space in the neovim command line for displaying messages
    completeopt = {
        'menuone',
        'noselect',
    },                      -- mostly just for cmp
    conceallevel = 0,       -- so that `` is visible in markdown files
    fileencoding = 'utf-8', -- the encoding written to a file
    hlsearch = true,        -- highlight all matches on previous search pattern
    ignorecase = true,      -- ignore case in search patterns
    mouse = 'a',            -- allow the mouse to be used in neovim
    pumheight = 10,         -- pop up menu height
    showmode = false,       -- show mode like -- INSERT --
    showtabline = 4,        -- always show tabs
    smartcase = true,       -- smart case
    smartindent = true,     -- make indenting smarter again
    splitbelow = true,      -- force all horizontal splits to go below current window
    splitright = true,      -- force all vertical splits to go to the right of current window
    swapfile = false,       -- disable creates a swapfile
    timeoutlen = 400,       -- time to wait for a mapped sequence to complete (in milliseconds)
    undofile = true,        -- enable persistent undo
    updatetime = 300,       -- faster completion (4000ms default)
    writebackup = false,    -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
    expandtab = true,       -- convert tabs to spaces
    shiftwidth = 4,         -- the number of spaces inserted for each indentation
    tabstop = 2,            -- insert 2 spaces for a tab
    softtabstop = 2,        -- insert 2 spaces for a tab
    cursorline = true,      -- highlight the current line
    number = true,          -- set numbered lines
    relativenumber = true,  -- set relative numbered lines
    numberwidth = 2,        -- set number column width to 2 {default 4}
    signcolumn = 'yes',     -- always show the sign column, otherwise it would shift the text each time
    wrap = false,           -- display lines as one long line
    scrolloff = 10,         -- is one of my fav
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
pcall(vim.cmd, [[set iskeyword+=-]])
-- vim.cmd([[set iskeyword+=-]])

-- util functions
local store_buf_to_buflist = function()
    -- add preview window to buffer list
    local buffer_num = vim.api.nvim_get_current_buf() -- current buffer
    vim.api.nvim_buf_set_option(buffer_num, "buflisted", true)
end;

-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "tokyonight-night"
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
lvim.keys.normal_mode['<C-BS>'] = '<Del>'
lvim.keys.insert_mode['<C-BS>'] = '<Del>'

-- Resize with arrows
lvim.keys.normal_mode['<Up>'] = ':resize -2<CR>'
lvim.keys.normal_mode['<Down>'] = ':resize +2<CR>'
lvim.keys.normal_mode['<Left>'] = ':vertical resize -2<CR>'
lvim.keys.normal_mode['<Right>'] = ':vertical resize +2<CR>'

-- Move text up and down
-- lvim.keys.normal_mode['√'] = ':m .+1<CR>=='
-- lvim.keys.normal_mode['ª'] = ':m .-2<CR>=='

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

-- move "marks" key from ` to ¨ for convenience on swedish keyboard
lvim.keys.normal_mode["ä"] = '`'

-- toggle capital or uncapitalized char & stay on same char
lvim.keys.normal_mode["§"] = "~h"

--- go-to preview keys
-- lvim.keys.normal_mode["<C-w>L"] = function()
--     store_buf_to_buflist()
--     vim.cmd("vert botright split")
-- end

-- lvim.keys.normal_mode["<C-w>K"] = function()
--     store_buf_to_buflist()
--     vim.cmd("topleft split")
-- end

-- lvim.keys.normal_mode["<C-w>J"] = function()
--     store_buf_to_buflist()
--     vim.cmd("botright split")
-- end

-- lvim.keys.normal_mode["<C-w>H"] = function()
--     store_buf_to_buflist()
--     vim.cmd("vert topleft split")
-- end

lvim.keys.insert_mode["jj"] = "<esc>"

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

-- WHICH_KEY config
lvim.builtin.which_key.setup.plugins.marks = true
lvim.builtin.which_key.setup.plugins.registers = true

for k in pairs(lvim.builtin.which_key.setup.plugins.presets) do
    lvim.builtin.which_key.setup.plugins.presets[k] = true
end


-- TELESCOPE config
lvim.builtin.telescope.pickers.find_files.previewer = true
-- lvim.builtin.telescope.pickers.buffers.previewer = true

-- space + r to replace all occurences of the word under the cursor
lvim.builtin.which_key.mappings["r"] = { ':%s/<C-R><C-W>/', "replace all" }
lvim.builtin.which_key.mappings["y"] = {
    name = "+Yank",
    w = { "viwy", "word" },
    a = { "ggVGy", "all" },
    p = { "viw\"_dP", "Paste over word" }
}
lvim.builtin.which_key.mappings["g"]["S"] = { "<cmd>Git stage_buffer<CR>", "Stage buffer" }
lvim.builtin.which_key.mappings["s"]["l"] = { "<cmd>Telescope resume<CR>", "Last search" }
lvim.builtin.which_key.mappings["s"]["s"] = { "<cmd>Telescope sessions_picker<CR>", "Sessions" }
lvim.builtin.which_key.mappings["g"]["q"] = { "<cmd>Gitsigns setqflist<CR>", "Quickfix hunks" }
lvim.builtin.which_key.mappings["s"]["T"] = {
    "<cmd>lua require('telescope.builtin').live_grep{ cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1] }<CR>",
    "text from root" }
lvim.builtin.which_key.mappings["s"]["m"] = { "<cmd>Telescope marks<CR>", "Marks" }
lvim.builtin.which_key.mappings["b"]["t"] = {
    "<cmd>lua require('telescope.builtin').live_grep({grep_open_files=true})<CR>",
    "text in buffers" }
lvim.builtin.which_key.mappings["g"]["c"] = {
    name = "+Conflict",
    q = { "<cmd>GitConflictListQf<cr>", "Quickfix list" },
    j = { "<cmd>GitConflictNextConflict<cr>", "Next conflict" },
    k = { "<cmd>GitConflictPrevConflict<cr>", "Prev conflict" },
    o = { "<cmd>GitConflictChooseOurs<cr>", "Choose ours" },
    t = { "<cmd>GitConflictChooseTheirs<cr>", "Choose theirs," },
    b = { "<cmd>GitConflictChooseBoth<cr>", "Choose both" },
}
lvim.builtin.which_key.mappings["m"] = {
    name = "+Mind",
    o = { "<cmd>MindOpenMain<cr>", "Open main" },
    r = { "<cmd>MindReloadState<cr>", "Reload" },
    c = { "<cmd>MindClose<cr>", "Close" },
}


-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- LSP settings
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {
        --     -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
        command = "prettier",
        filetypes = { "json", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    },
    -- { command = "stylelua", filetypes = { "lua" }}
}

-- additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    -- {
    --     command = "eslint",
    --     filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    -- },
    {
        command = "markdownlint",
        filetypes = { "markdown" }
    }
    --     { command = "luacheck", filetypes = { "lua" }}
}

-- set up language servers
require("lvim.lsp.manager").setup("eslint")
require("lvim.lsp.manager").setup("tsserver")
require("lvim.lsp.manager").setup("lua_ls")
require("lvim.lsp.manager").setup("bashls")
require("lvim.lsp.manager").setup("jsonls")
require("lvim.lsp.manager").setup("markdownlint")

-- remapping vim-visual-multi keys
vim.keymap.set(
    { "n" },
    "º",
    ":call vm#commands#add_cursor_up(0, v:count1)<cr>",
    { noremap = true, silent = true }
)


vim.keymap.set(
    { "n" },
    "¬",
    ":call vm#commands#add_cursor_down(0, v:count1)<cr>",
    { noremap = true, silent = true }
)

-- Additional Plugins
lvim.plugins = {
    {
        'AhmedAbdulrahman/aylin.vim',
    },
    {
        'mg979/vim-visual-multi',
        -- branch = 'master',
        config = function()
            -- let g:VM_maps = {}
            -- let g:VM_maps["Add Cursor Down"] = '¬'

            vim.g.VM_maps = {
                    ["Add Cursor Down"] = "¬",
                    ["Add Cursor Up"] = "º",
                    ["Select Cursor Down"] = "¬",
                    ["Select Cursor Up"] = "º",
            }
            vim.g.VM_theme = 'codedark'
        end
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
    {
        'akinsho/git-conflict.nvim',
        version = "*",
        config = function()
            require('git-conflict').setup({
                {
                    disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
                    highlights = {
                        -- They must have background color, otherwise the default color will be used
                        incoming = 'DiffText',
                        current = 'DiffAdd',
                    }
                }
            })
        end
    },
    {
        "gen740/SmoothCursor.nvim",
        config = function()
            require("smoothcursor").setup({
                autostart = true,
                cursor = "",    -- cursor shape (need nerd font)
                intervals = 35,    -- tick interval
                linehl = nil,      -- highlight sub-cursor line like 'cursorline', "CursorLine" recommended
                type = "default",  -- define cursor movement calculate function, "default" or "exp" (exponential).
                fancy = {
                    enable = true, -- enable fancy mode
                    head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
                    body = {
                        { cursor = "▓", texthl = "SmoothCursorAqua" },
                        { cursor = "▓", texthl = "SmoothCursorAqua" },
                        { cursor = "▒", texthl = "SmoothCursorAqua" },
                        { cursor = "▒", texthl = "SmoothCursorBlue" },
                        { cursor = "▒", texthl = "SmoothCursorBlue" },
                        { cursor = "░", texthl = "SmoothCursorPurple" },
                        { cursor = "░", texthl = "SmoothCursorPurple" },
                        { cursor = "░", texthl = "SmoothCursorPurple" },
                    },
                    tail = { cursor = nil, texthl = "SmoothCursor" }
                },
                priority = 10,           -- set marker priority
                speed = 45,              -- max is 100 to stick to your current position
                texthl = "SmoothCursor", -- highlight group, default is { bg = nil, fg = "#FFD400" }
                threshold = 3,
                timeout = 3000,
            })
        end
    },
    {
        "ggandor/lightspeed.nvim",
    },
    {
        "nvim-telescope/telescope-live-grep-args.nvim"
    },
    {
        "junegunn/fzf",
        build = function()
            vim.fn['fzf#install']()
        end
    },
    -- { 'RRethy/vim-illuminate' },
    {
        'levouh/tint.nvim',
        config = function()
            require('tint').setup()
        end
    },
    {
        'echasnovski/mini.sessions',
        config = function()
            require("mini.sessions").setup({})
        end
    },
    {
        'echasnovski/mini.animate',
        config = function()
            local animate = require("mini.animate")

            animate.setup({
                cursor = {
                    enable = true
                },
                resize = {
                    enable = false
                },
                scroll = {
                    timing = animate.gen_timing.linear({
                        easing = "out",
                        duration = 125,
                        unit = "total"
                    })
                }
            })
        end
    },
    {
        'echasnovski/mini.move',
        config = function()
            require('mini.move').setup({
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
                    left = '˛',
                    right = 'ﬁ',
                    down = '√',
                    up = 'ª',
                    -- Move current line in Normal mode
                    line_left = '<Nop>',
                    line_right = '<Nop>ﬁ',
                    line_down = '√',
                    line_up = 'ª',
                },
            })
        end
    },
    {
        'phaazon/mind.nvim',
        branch = 'v2.2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require 'mind'.setup()
        end
    },
    { "shortcuts/no-neck-pain.nvim", version = "*" },
    {
        "JoseConseco/telescope_sessions_picker.nvim"
    },
    {
        'rmagatti/goto-preview',
        config = function()
            local gtp = require('goto-preview')
            local select_to_edit_map = {
                default  = "edit",
                up       = "topleft split",
                right    = "vert botright split",
                down     = "botright split",
                left     = "vert topleft split",
                next     = "wincmd w",
                previous = "wincmd W",
            }

            local function open_file(orig_window, filename, cursor_position, command)
                if orig_window ~= 0 and orig_window ~= nil then
                    vim.api.nvim_set_current_win(orig_window)
                end

                pcall(vim.cmd, string.format('%s %s', command, filename))
                vim.api.nvim_win_set_cursor(0, cursor_position)
            end

            local function open_preview(preview_win, type)
                return function()
                    local command         = select_to_edit_map[type]
                    local orig_window     = vim.api.nvim_win_get_config(preview_win).win
                    local cursor_position = vim.api.nvim_win_get_cursor(preview_win)
                    local filename        = vim.api.nvim_buf_get_name(0)

                    vim.api.nvim_win_close(preview_win, gtp.conf.force_close)
                    open_file(orig_window, filename, cursor_position, command)

                    local buffer = vim.api.nvim_get_current_buf()
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<C-w>l')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<C-w>k')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<C-w>j')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<C-w>h')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<CR>')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<S-L>')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<S-H>')
                end
            end

            local function cycle_preview(direction)
                return function()
                    local all_windows = vim.api.nvim_tabpage_list_wins(0)
                    local current_window = vim.api.nvim_get_current_win()

                    for i = 1, #all_windows do
                        local j = (i + direction - 1) % #all_windows + 1
                        local win = all_windows[j]

                        if vim.api.nvim_win_get_config(win).relative ~= "" and win ~= current_window then
                            vim.api.nvim_set_current_win(win)
                            break
                        end
                    end
                end
            end

            local function post_open_hook(buf, win)
                vim.keymap.set('n', '<C-w>l', open_preview(win, "right"), { buffer = buf })
                vim.keymap.set('n', '<C-w>k', open_preview(win, "up"), { buffer = buf })
                vim.keymap.set('n', '<C-w>j', open_preview(win, "down"), { buffer = buf })
                vim.keymap.set('n', '<C-w>h', open_preview(win, "left"), { buffer = buf })
                vim.keymap.set('n', '<CR>', open_preview(win, "default"), { buffer = buf })
                vim.keymap.set('n', '<S-L>', cycle_preview(1), { buffer = buf })
                vim.keymap.set('n', '<S-H>', cycle_preview(-1), { buffer = buf })
            end

            gtp.setup({
                default_mappings = true,
                post_open_hook = post_open_hook,
            })
        end
    }
}


lvim.builtin.telescope.on_config_done = function(tele)
    tele.extensions = {
        sessions_picker = {
            sessions_dir = vim.fn.stdpath('data') .. "/session" -- same as '/Users/{user}/.local/share/nvim/session'
        }
    }

    tele.load_extension("sessions_picker")
end

-- PLUGIN OVERRIDES --
-- open terminal
lvim.builtin.terminal.open_mapping = "<C-SPACE>"

lvim.builtin.which_key.disable = false

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

-- lvim.transparent_window = true
--
