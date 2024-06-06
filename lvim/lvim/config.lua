--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
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
lvim.colorscheme = "nordic"
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

-- Copilot keymaps
lvim.keys.insert_mode["<C-h>"] = '<Plug>(copilot-dismiss)'
lvim.keys.insert_mode["<C-j>"] = '<Plug>(copilot-next)'
lvim.keys.insert_mode["<C-k>"] = '<Plug>(copilot-previous)'
lvim.keys.insert_mode["<C-l>"] = '<Plug>(copilot-accept-line)'
lvim.keys.insert_mode["<C-L>"] = '<Plug>(copilot-accept-word)'
lvim.keys.insert_mode["<C-J>"] = '<Plug>(copilot-suggest)'

-- WHICH_KEY config
lvim.builtin.which_key.setup.plugins.marks = true
lvim.builtin.which_key.setup.plugins.registers = true

for k in pairs(lvim.builtin.which_key.setup.plugins.presets) do
    lvim.builtin.which_key.setup.plugins.presets[k] = true
end

-- TELESCOPE config
lvim.builtin.telescope.pickers.find_files.previewer = true
lvim.builtin.telescope.defaults.preview = {
    treesitter = false,
    timeout = 250
}
-- lvim.builtin.telescope.pickers.buffers.previewer = true

-- space + r to replace all occurences of the word under the cursor
lvim.builtin.which_key.mappings["n"] = { '<cmd>Navbuddy<CR>', "Navbuddy" }
lvim.builtin.which_key.mappings["r"] = { ':%s/<C-R><C-W>/', "replace all" }
lvim.builtin.which_key.mappings["y"] = {
    name = "+Yank",
    w = { "viwy", "word" },
    a = { "ggVGy", "all" },
    -- p = { "viw\"_dP", "Paste over word" }
}
lvim.builtin.which_key.mappings["u"] = {
    "<cmd>TransparentToggle<CR>", "Toggle transparent"
}
lvim.builtin.which_key.mappings["g"]["S"] = { "<cmd>Git stage_buffer<CR>", "Stage buffer" }
lvim.builtin.which_key.mappings["s"]["l"] = { "<cmd>Telescope resume<CR>", "Last search" }
lvim.builtin.which_key.mappings["g"]["q"] = { "<cmd>Gitsigns setqflist<CR>", "Quickfix hunks" }
-- lvim.builtin.which_key.mappings["s"]["T"] = {
--     "<cmd>lua require('telescope.builtin').live_grep{ cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1] }<CR>",
--     "text from root" }
lvim.builtin.which_key.mappings["s"]["w"] = {
    "<cmd>Telescope projects<CR>",
    "workspaces" }
lvim.builtin.which_key.mappings["s"]["m"] = { "<cmd>Telescope marks<CR>", "Marks" }
lvim.builtin.which_key.mappings["s"]["s"] = { "<cmd>Telescope possession list<CR>", "Sessions" }
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
lvim.builtin.which_key.mappings["z"] = {
    "<cmd>ZenMode<CR>", "Zen mode"
}


-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.icons.ui.Folder = ""
-- lvim.builtin.nvimtree.setup.icons.glyphs.folder.default = ""
--
-- nvim-tree
-- lvim.builtin.nvimtree.setup = {
--     icons = {
--         glyphs = {
--             default = "",
--             symlink = "",
--             bookmark = "",
--             modified = "●",
--             folder = {
--                 arrow_closed = "",
--                 arrow_open = "",
--                 default = "",
--                 open = "",
--                 empty = "",
--                 empty_open = "",
--                 symlink = "",
--                 symlink_open = "",
--             },
--             git = {
--                 unstaged = "✗",
--                 staged = "✓",
--                 unmerged = "",
--                 renamed = "➜",
--                 untracked = "★",
--                 deleted = "",
--                 ignored = "◌",
--             },
--         }
--     }
-- }


-- LSP settings
-- local bun_servers = { "tsserver", "eslint" }

-- local function is_bun_server(name)
--     for _, server in ipairs(bun_servers) do
--         if server == name then
--             return true
--         end
--     end
--     return false
-- end

-- local function is_bun_available()
--     return vim.fn.executable("bunx") == 1
-- end

-- local add_bun_prefix = function(config, user_config)
--     if config.cmd and is_bun_available() and is_bun_server(config.name) then
--         config.cmd = vim.list_extend({ "bunx" }, config.cmd)
--         -- table.insert(config.cmd, 1, "bunx")
--     end
-- end

local util = require("lspconfig.util")
-- util.on_setup = util.add_hook_before(util.on_setup, add_bun_prefix)

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
    {
        command = "actionlint",
        filetypes = { "yaml" }
    },
    {
        command = "jsonlint",
        filetpyes = { "json" }
    }
    -- {
    --     command = "eslint_d",
    --     filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    -- },
    --     {
    --         command = "markdownlint",
    --         filetypes = { "markdown" }
    --     }
    --     --     { command = "luacheck", filetypes = { "lua" }}
}

-- set up language servers
local navbuddySuccess, navbuddy = pcall(require, "nvim-navbuddy")
local lspManager = require "lvim.lsp.manager"

-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers,
--     { "tsserver", "lua_ls", "bashls", "jsonls", "markdownlint" })

-- REPLACED BY typescript-tools.nvim plugin
lspManager.setup("tsserver", {
    -- on_setup = util.add_hook_before(util.on_setup, add_bun_prefix),
    on_attach = function(client, bufnr)
        if navbuddySuccess then
            navbuddy.attach(client, bufnr)
        end
    end
})
lspManager.setup("eslint")

lspManager.setup("lua_ls", {
    on_attach = function(client, bufnr)
        if navbuddySuccess then
            navbuddy.attach(client, bufnr)
        end
    end
})
lspManager.setup("bashls")
lspManager.setup("jsonls", {
    on_attach = function(client, bufnr)
        if navbuddySuccess then
            navbuddy.attach(client, bufnr)
        end
    end
})
lspManager.setup("markdownlint", {
    on_attach = function(client, bufnr)
        if navbuddySuccess then
            navbuddy.attach(client, bufnr)
        end
    end
})

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
        lazy = true,
    },
    {
        'mg979/vim-visual-multi',
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
        event = { "BufRead", "BufNew" },
        config = function()
            require('nvim-surround').setup()
        end
    },
    {
        'wfxr/minimap.vim',
        cmd = "Minimap",
        lazy = true,
        -- config = "require('plugins.minimap')",
    },
    {
        "kevinhwang91/nvim-bqf",
        lazy = true,
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
        lazy = true,
        version = "*",
        cmd = { "GitConflictListQf", "GitConflictNextConflict", "GitConflictPrevConflict", "GitConflictChooseOurs",
            "GitConflictChooseTheirs", "GitConflictChooseBoth" },
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
        lazy = true,
        event = { "BufRead", "BufNew" },
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
        event = { "BufRead", "BufNew" },
    },
    -- {
    --     "nvim-telescope/telescope-live-grep-args.nvim",
    --     lazy = true
    -- },
    {
        "junegunn/fzf",
        build = function()
            vim.fn['fzf#install']()
        end
    },
    -- { 'RRethy/vim-illuminate' },
    {
        'levouh/tint.nvim',
        event = "VimResized",
        lazy = true,
        config = function()
            require('tint').setup()
        end
    },
    -- {
    --     'echasnovski/mini.sessions',
    --     config = function()
    --         require("mini.sessions").setup({})
    --     end
    -- },
    -- {
    --     'echasnovski/mini.animate',
    --     event = { "BufRead", "BufNew" },
    --     config = function()
    --         local animate = require("mini.animate")

    --         animate.setup({
    --             cursor = {
    --                 enable = true
    --             },
    --             resize = {
    --                 enable = false
    --             },
    --             scroll = {
    --                 timing = animate.gen_timing.linear({
    --                     easing = "out",
    --                     duration = 125,
    --                     unit = "total"
    --                 })
    --             }
    --         })
    --     end
    -- },
    {
        'echasnovski/mini.move',
        event = { "BufRead", "BufNew" },
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
        lazy = true,
        cmd = { "MindOpenMain", "MindReloadState", "MindClose" },
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require 'mind'.setup()
        end
    },
    {
        'jedrzejboczar/possession.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require("possession").setup({})
        end
    },
    { "shortcuts/no-neck-pain.nvim", lazy = true,       cmd = "NoNeckPain", version = "*" },
    {
        "SmiteshP/nvim-navbuddy",
        lazy = true,
        event = { "BufNew", "BufRead" },
        dependencies = {
            "neovim/nvim-lspconfig",
            "SmiteshP/nvim-navic",
            "MunifTanjim/nui.nvim"
        },
        opts = {
            lsp = {
                auto_attach = true
            }
        }
    },
    {
        'rmagatti/goto-preview',
        event = { "BufNew", "BufRead" },
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

            -- new stuff
            local original_keymaps = {}
            local open_previews = {}

            local function store_original_keymaps(buf)
                local maps = vim.keymap.get('', { buffer = buf })
                original_keymaps[buf] = {}

                for _, m in ipairs(maps) do
                    table.insert(original_keymaps[buf], {
                        mode = m.mode,
                        lhs = m.lhs,
                        rhs = m.rhs,
                        silent = m.silent,
                        expr = m.expr,
                        noremap = m.noremap,
                        nowait = m.nowait
                    })
                end
            end

            local function restore_original_keymaps(buf)
                local maps = original_keymaps[buf] or {}

                for _, m in ipairs(maps) do
                    vim.api.nvim_buf_set_keymap(buf, m.mode, m.lhs, m.rhs, {
                        silent = m.silent,
                        expr = m.expr,
                        noremap = m.noremap,
                        nowait = m.nowait
                    })
                end
            end

            function _G.restore_keybindings_on_floating_window_close()
                local floating_windows = vim.tbl_filter(function(w)
                    return vim.api.nvim_win_get_config(w).relative ~= ""
                end, vim.api.nvim_tabpage_list_wins(0))

                for _, win in ipairs(floating_windows) do
                    -- picks buffer from opened preview windows
                    local buf = open_previews[win]

                    -- if it exists, try to restore original key bindings
                    if buf then
                        restore_original_keymaps(buf)
                        -- remove preview window from list
                        open_previews[win] = nil
                    end
                end
            end

            local function open_file(orig_window, filename, cursor_position, command)
                if orig_window ~= 0 and orig_window ~= nil then
                    vim.api.nvim_set_current_win(orig_window)
                end

                pcall(function() vim.cmd(string.format('%s %s', command, filename)) end)
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
                    store_original_keymaps(buffer)

                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<C-w>l')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<C-w>k')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<C-w>j')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<C-w>h')
                    vim.api.nvim_buf_del_keymap(buffer, 'n', '<CR>')
                    -- vim.api.nvim_buf_del_keymap(buffer, 'n', '<S-L>')
                    -- vim.api.nvim_buf_del_keymap(buffer, 'n', '<S-H>')

                    -- stores buffer in preview window id list
                    open_previews[preview_win] = buffer
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
                -- local current_buf = vim.api.nvim_get_current_buf()
                vim.keymap.set('n', '<C-w>l', open_preview(win, "right"), { buffer = buf })
                vim.keymap.set('n', '<C-w>k', open_preview(win, "up"), { buffer = buf })
                vim.keymap.set('n', '<C-w>j', open_preview(win, "down"), { buffer = buf })
                vim.keymap.set('n', '<C-w>h', open_preview(win, "left"), { buffer = buf })
                vim.keymap.set('n', '<CR>', open_preview(win, "default"), { buffer = buf })
                -- vim.keymap.set('n', '<S-L>', cycle_preview(1), { buffer = buf })
                -- vim.keymap.set('n', '<S-H>', cycle_preview(-1), { buffer = buf })
            end

            -- vim.cmd([[autocmd WinClosed * lua _G.restore_keybindings_on_floating_window_close()]])
            -- vim.cmd([[autocmd WinClosed * lua _G.restore_keybindings_on_floating_window_close()]])
            -- vim.cmd([[autocmd WinClosed * lua _G.restore_keybindings_on_floating_window_close()]])

            gtp.setup({
                default_mappings = true,
                post_open_hook = post_open_hook,
            })
        end
    },
    {
        "chrishrb/gx.nvim",
        event = { "BufEnter" },
        config = true, -- default settings
    },
    {
        "xiyaowong/transparent.nvim",
        config = function()
            require("transparent").setup({
                groups = { -- table: default groups
                    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
                    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
                    'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
                    'SignColumn', 'CursorLineNr', 'EndOfBuffer', 'NormalSB', 'Pmenu',
                },
                extra_groups = {   -- table: additional groups that should be cleared
                    'NormalFloat', -- plugins which have float panel such as Lazy, Mason, LspInfo
                    'FloatBorder',
                    'NvimTreeWinSeparator',
                    'NvimTreeNormal',
                    'NvimTreeNormalNC',
                    'TroubleNormal',
                    'TelescopeNormal',
                    'TelescopeBorder',
                    'WhichKeyFloat',
                },
            })
        end
    },
    {
        'AckslD/muren.nvim',
        config = true,
    },
    {
        'ribru17/bamboo.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('bamboo').setup {
                -- optional configuration here
            }
            require('bamboo').load()
        end,
    },
    {
        'rebelot/kanagawa.nvim',
        config = true
    },
    { 'rose-pine/neovim',            name = 'rose-pine' },
    { 'sainnhe/everforest',          config = true },
    { "shaunsingh/moonlight.nvim",   name = "moonlight" },
    { "andersevenrud/nordic.nvim",   name = "nordic" },
    -- {
    --     "pmizio/typescript-tools.nvim",
    --     dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    --     opts = {},
    -- }
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
            require("treesitter-context").setup({
                mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = "–",
                -- How many lines the window should span. Values <= 0 mean no limit.
                max_lines = 4
            })
        end
    },
    {
        "gungun974/nvim-ts-autotag",
        --     -- "windwp/nvim-ts-autotag",
        --     -- branch = "gungun974:main",
        -- config = function()
        --     require("nvim-ts-autotag").setup()
        -- end
    },
    {
        "folke/twilight.nvim",
        opts = {}
    },
    {
        "folke/zen-mode.nvim",
        opts = {
            plugins = {
                twilight = {
                    enabled = false
                },
            }
        }
    },
    {
        "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async"
    },
    {
        "github/copilot.vim",
        event = "BufRead",
        config = function()
            -- Mapping tab is already used by NvChad
            vim.g.copilot_no_tab_map = true;
            vim.g.copilot_assume_mapped = true;
            vim.g.copilot_tab_fallback = "";
            -- The mapping is set to other key, see custom/lua/mappings
            -- or run <leader>ch to see copilot mapping section
        end
    },
    {
        "camspiers/snap",
        config = function()
            local snap = require "snap"
            local function git_root_path()
                return vim.fn.systemlist('git rev-parse --show-toplevel')[1]
            end

            -- local git_root_grep_producer =
            --     snap.get "consumer.cache" (
            --         function(request)
            --             snap.get "producer.ripgrep.general" (
            --                 request,
            --                 {
            --                     absolute = true,
            --                     args = {
            --                         "--line-buffered", "-M", 100, "--vimgrep"
            --                         -- '--line-buffered',
            --                         -- '--vimgrep',
            --                         -- '--hidden',
            --                         -- '--ignore-case'
            --                         -- '-M',
            --                         -- '100',
            --                         -- request.filter
            --                     },
            --                     cwd = '/Users/leo.karlsson/ATG/atgse'
            --                     -- cwd = snap.sync(vim.fn.getcwd)
            --                     -- cwd = snap.sync(git_root_path)
            --                     -- cwd = git_root_path
            --                 }
            --             )
            --         end
            --     )

            -- snap.register.map('n', '<leader>o', function()
            --     snap.run {
            --         -- prompt = "grep",
            --         producer = git_root_grep_producer,
            --         steps = { {
            --             consumer = snap.get 'consumer.fzf',
            --             config = { prompt = "FZF>" }
            --         } },
            --         select = snap.get "select.vimgrep".select,
            --         multiselect = snap.get "select.vimgrep".multiselect,
            --         views = { snap.get "preview.vimgrep" },
            --     }
            -- end)

            -- MUST change line 5 in lua/snap/common/string.lua to
            -- package.loaded[_2amodule_name_2a] = string <-- changed {} to string
            snap.register.map({ "n" }, { "<Leader>sT" }, function()
                snap.run {
                    producer = snap.get 'producer.ripgrep.vimgrep'.args({
                        '--hidden',
                        -- '--ignore-case'
                    }, git_root_path()),
                    select = snap.get 'select.vimgrep'.select,
                    multiselect = snap.get 'select.vimgrep'.multiselect,
                    views = { snap.get 'preview.vimgrep' },
                    steps = { {
                        consumer = snap.get 'consumer.fzf',
                        config = { prompt = "FZF>" }
                    } },
                }
            end)

            snap.maps {
                { "<Leader>sF", snap.config.file { producer = "ripgrep.file", prompt = "files" } },
                { "<Leader>st", snap.config.vimgrep { prompt = "grep" } },
            }
        end
    }
}

-- vim.keymap.set('i', '<C-h>', '<Plug>(copilot-dismiss)')
-- vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)')
-- vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)')
-- vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-line)')
-- vim.keymap.set('i', '<C-L>', '<Plug>(copilot-accept-word)')
-- vim.keymap.set('n', '<C-J>', '<Plug>(copilot-suggest)')


-- Folding config
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}
local language_servers = require("lspconfig").util.available_servers()
for _, ls in ipairs(language_servers) do
    require("lspconfig")[ls].setup({
        capabilities = capabilities
    })
end
require("ufo").setup()

lvim.builtin.telescope.on_config_done = function(tele)
    tele.load_extension("possession")
end

local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
    return
end

-- lvim.builtin.cmp.mapping = {
-- {}
--       -- ["<C-Space>"] = cmp_mapping.complete(),
-- }



-- PLUGIN OVERRIDES --
-- open terminal
lvim.builtin.terminal.open_mapping = "<C-SPACE>"
lvim.builtin.which_key.disable = false
lvim.builtin.treesitter.autotag = {
    enable = true
}

-- lvim.builtin.nvimtree.setup.prefer_startup_root = true -- if update_focused_file is enabled
-- lvim.builtin.nvimtree.setup.update_cwd = false
-- lvim.builtin.nvimtree.setup.update_focused_file = {
--     enable = false,
--     update_root = false,
--     ignore_list = {},
-- }
-- lvim.builtin.nvimtree.setup.hijack_directories = {
--     enable = false,
--     auto_open = false,
-- }
-- lvim.builtin.nvimtree.setup.actions.change_dir.enable = false

-- lvim.transparent_window = true

-- vim.cmd([[
--     augroup quickfix_keybindings
--       autocmd!
--       autocmd FileType qf nnoremap <buffer> zr :cfdo %s:SEARCH_WORD:REPLACE_WORD:g <Bar> update <Bar> bdelete
--     augroup END
-- ]])







-- Place this script in your init.lua or source it from your init.vim
-- local function create_floating_win()
--     local buf = vim.api.nvim_create_buf(false, true)
--     local width = 50
--     local height = 4
--     local win_opts = {
--         style = "minimal",
--         relative = "editor",
--         width = width,
--         height = height,
--         row = math.floor((vim.o.lines - height) / 2 - 1),
--         col = math.floor((vim.o.columns - width) / 2)
--     }

--     local win = vim.api.nvim_open_win(buf, true, win_opts)

--     vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
--     vim.api.nvim_win_set_option(win, "winhl", "Normal:Floating")
--     vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
--         "Enter search word:",
--         "Enter replace word:"
--     })

--     vim.api.nvim_win_set_cursor(win, { 2, 0 })

--     return buf, win
-- end

-- local function close_floating_win(buf, win)
--     vim.api.nvim_win_close(win, true)
--     vim.api.nvim_buf_delete(buf, { force = true })
-- end

-- _G.input_words_and_run_cfdo = function()
--     local buf, win = create_floating_win()
--     local search_word = ""
--     local replace_word = ""

--     local function on_enter()
--         close_floating_win(buf, win)
--         vim.cmd("cfdo %s/" .. search_word .. "/" .. replace_word .. "/g | update | bdelete")
--     end

--     local function on_key(pressed_key)
--         local processed_key = vim.api.nvim_replace_termcodes(pressed_key, true, true, true)
--         if processed_key == "<CR>" then
--             if search_word == "" then
--                 search_word = vim.fn.getline("."):sub(19)
--                 vim.api.nvim_win_set_cursor(win, { 3, 18 })
--             elseif replace_word == "" then
--                 replace_word = vim.fn.getline("."):sub(19)
--                 on_enter()
--             end
--         end
--     end

--     vim.api.nvim_buf_attach(buf, false, {
--         on_detach = function()
--             close_floating_win(buf, win)
--         end,
--         on_changedtick = function(_, _, _, _)
--             local pressed_key = vim.api.nvim_get_keymap("i")[1].rhs
--             on_key(pressed_key)
--         end
--     })

--     vim.cmd("startinsert!")
-- end

-- -- Replace <leader>r with your desired keybinding
-- -- vim.api.nvim_set_keymap("n", "<leader>r", ":lua input_words_and_run_cfdo()<CR>", {noremap = true, silent = true})
-- vim.cmd([[
--     augroup quickfix_keybindings
--       autocmd!
--       autocmd FileType qf nnoremap <buffer> zr :lua input_words_and_run_cfdo()<CR>
--     augroup END
-- ]])
--
--
--
--

local function create_floating_win()
    local search_buf = vim.api.nvim_create_buf(false, true)
    local replace_buf = vim.api.nvim_create_buf(false, true)
    local width = 50
    local height = 1
    local search_buf_opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2 - 1),
        col = math.floor((vim.o.columns - width) / 2),
        border = "single",
        title = "Search",
        title_pos = 'left',
    }
    local replace_buf_opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2 + 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = "single",
        title = "Replace",
        title_pos = 'left',
    }

    local search_win = vim.api.nvim_open_win(search_buf, true, search_buf_opts)
    local replace_win = vim.api.nvim_open_win(replace_buf, false, replace_buf_opts)

    vim.api.nvim_buf_set_option(search_buf, "bufhidden", "wipe")
    vim.api.nvim_win_set_option(search_win, "winhl", "Normal:Floating")
    vim.api.nvim_buf_set_option(replace_buf, "bufhidden", "wipe")
    vim.api.nvim_win_set_option(replace_win, "winhl", "Normal:Floating")

    vim.api.nvim_win_set_cursor(search_win, { 1, 0 })

    local bufs = {
        search = search_buf,
        replace = replace_buf
    }

    local wins = {
        search = search_win,
        replace = replace_win,
    }
    return bufs, wins
end

local function close_floating_win(wins)
    for _, win in pairs(wins) do
        vim.api.nvim_win_close(win, true)
    end

    vim.cmd("stopinsert")
end

local function input_words_and_run_cfdo()
    local bufs, wins = create_floating_win()

    for _, buf in pairs(bufs) do
        vim.keymap.set({ "n", "i", "v" }, "<Esc>", function()
            close_floating_win(wins)
        end, { buffer = buf })

        vim.keymap.set({ "n", "i", "v" }, "<CR>", function()
            local search_word = vim.api.nvim_buf_get_lines(bufs.search, 0, -1, true)[1]
            local replace_word = vim.api.nvim_buf_get_lines(bufs.replace, 0, -1, true)[1]

            print(search_word)
            close_floating_win(wins)
            vim.cmd("cfdo %s/" ..
                vim.fn.escape(search_word, "/") .. "/" .. vim.fn.escape(replace_word, "/") .. "/g | update | bdelete")
        end, { buffer = buf })

        local move_focus_keys = { "<Tab>", "<S-Tab>", "<C-j>", "<C-k>" }

        for _, key in ipairs(move_focus_keys) do
            vim.keymap.set({ "n", "i", "v" }, key,
                function()
                    local focused_win = vim.api.nvim_get_current_win()
                    local target_win = focused_win == wins.search and wins.replace or wins.search
                    vim.api.nvim_set_current_win(target_win)
                    vim.api.nvim_win_set_cursor(target_win, { 1, 0 })
                end,
                { buffer = buf })
        end
    end

    vim.cmd("startinsert")
end

_G.input_words_and_run_cfdo = input_words_and_run_cfdo

vim.cmd([[
    augroup quickfix_keybindings
      autocmd!
      autocmd FileType qf nnoremap <buffer> zr :lua input_words_and_run_cfdo()<CR>
    augroup END
]])


-- Define the Lua function
-- function OpenInIterm()
--     local file_path = vim.fn.expand('%:p')
--     -- local open_command = [[
--     -- osascript -e 'tell application "iTerm" to activate' \
--     -- -e 'tell application "System Events" to tell process "iTerm" to keystroke "n" using command down' \
--     -- -e 'tell application "System Events" to tell process "iTerm" to keystroke "u" using command down' \
--     -- -e 'tell application "System Events" to tell process "iTerm" to keystroke "lvim ']] .. file_path .. [[' \
--     -- -e 'tell application "System Events" to key code 52'
--     -- ]]
--     local open_command =
--     "osascript -e 'tell application \"iTerm\" to activate' -e 'tell application \"System Events\" to tell process \"iterm\" to keystroke \"n\" using command down' -e 'tell application \"system events\" to tell process \"iterm\" to keystroke \"u\" using command down' -e 'tell application \"system events\" to tell process \"iterm\" to keystroke \"lvim $1\"' -e 'tell application \"system events\" to key code 52'"

--     vim.cmd('term ' .. open_command)
--     vim.cmd('bd!')
--     -- capture output
--     -- local handle = io.popen(cmd)
--     -- local result = handle:read("*a")
--     -- handle:close()

--     -- -- print output
--     -- print(result)
--     -- -- vim.cmd('bd!')
--     -- os.execute(cmd)
--     -- vim.cmd('bd!')
-- end

-- local open_command =
-- "osascript -e 'tell application \"iTerm\" to activate' -e 'tell application \"System Events\" to tell process \"iterm\" to keystroke \"n\" using command down' -e 'tell application \"system events\" to tell process \"iterm\" to keystroke \"u\" using command down' -e 'tell application \"system events\" to tell process \"iterm\" to keystroke \"lvim $1\"' -e 'tell application \"system events\" to key code 52'"

-- lvim.builtin.which_key.mappings["<C-w>"] = {
--     N = ":term osascript -e 'tell application \"iTerm\" to activate' -e 'tell application \"System Events\" to tell process \"iterm\" to keystroke \"n\" using command down' -e 'tell application \"system events\" to tell process \"iterm\" to keystroke \"u\" using command down' -e 'tell application \"system events\" to tell process \"iterm\" to keystroke \"lvim " . shellescape(expand('%:p')) . "\"' -e 'tell application \"system events\" to key code 52'"
-- N =
-- [[:term osascript -e 'tell application "iTerm" to activate' -e 'tell application "System Events" to tell process "iterm" to keystroke "n" using command down' -e 'tell application "system events" to tell process "iterm" to keystroke "u" using command down' -e 'tell application "system events" to tell process "iterm" to keystroke "lvim " . shellescape(expand('%:p')) . "' -e 'tell application "system events" to key code 52']]
--     -- ":term osascript -e 'tell application \"iTerm\" to activate' -e 'tell application \"System Events\" to tell process \"iterm\" to keystroke \"n\" using command down' -e 'tell application \"system events\" to tell process \"iterm\" to keystroke \"u\" using command down' -e 'tell application \"system events\" to tell process \"iterm\" to keystroke \"lvim " . shellescape(expand('%:p')) . "\" -e 'tell application \"system events\" to key code 52'"
-- }
-- lvim.builtin.which_key.mappings["<C-w>"] = { N = "<cmd>term OpenInTerm()<CR>", "Open buffer in new iterm window" }
-- lvim.builtin.which_key.mappings["<C-w>"] = { N = "<cmd>lua OpenInTerm()<CR>", "Open buffer in new iterm window" }
