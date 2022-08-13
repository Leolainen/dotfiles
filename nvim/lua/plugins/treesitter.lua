local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

require('treesitter-context').setup({
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  throttle = true, -- Throttles plugin updates (may improve performance)
  max_lines = 4, -- How many lines the window should span. Values <= 0 mean no limit.
})

-- my languages
--    'css',
--    'dockerfile'
--    'javascript',
--    'javascriptreact',
--    'bash',
--    'comment',
--    'graphql',
--    'html',
--    'http',
--    'java',
--    'json',
--    'jsdoc',
--    'json5',
--    'lua',
--    'make',
--    'markdown',
--    'markdown_inline',
--    'regex',
--    'scss',
--    'tsx',
--    'typescript',
--    'vim',
--    'yaml',
--    'vue',

treesitter.setup({
  ensure_installed = {},
  ignore_install = { 'phpdoc', 'haskell', 'verilog' }, -- List of parsers to ignore installing
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },

  fold = {
    enable = true,
  },

  indent = {
    enable = true,
  },

  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },

  autotag = {
    enable = true,
    filetypes = {
      'html',
      'javascript',
      'javascriptreact',
      'typescriptreact',
      'svelte',
      'vue',
      'javascript.jsx',
      'typescript.tsx',
    },
  },

  autopairs = {
    enable = true,
  },

  -- probably something to learn for later
  -- textobjects = {
  --   move = {
  --     enable = true,
  --     set_jumps = true, -- whether to set jumps in the jumplist
  --     goto_next_start = {
  --       [']]'] = '@function.outer',
  --       [']m'] = '@class.outer',
  --     },
  --     goto_next_end = {
  --       [']['] = '@function.outer',
  --       [']M'] = '@class.outer',
  --     },
  --     goto_previous_start = {
  --       ['[['] = '@function.outer',
  --       ['[m'] = '@class.outer',
  --     },
  --     goto_previous_end = {
  --       ['[]'] = '@function.outer',
  --       ['[M'] = '@class.outer',
  --     },
  --   },
  --   select = {
  --     enable = true,
  --     -- Automatically jump forward to textobj, similar to targets.vim
  --     lookahead = true,
  --     keymaps = {
  --       -- You can use the capture groups defined in textobjects.scm
  --       ['af'] = '@function.outer',
  --       ['if'] = '@function.inner',
  --       ['ac'] = '@class.outer',
  --       ['ic'] = '@class.inner',
  --       ['aC'] = '@conditional.outer',
  --       ['iC'] = '@conditional.inner',
  --     },
  --   },
  -- },

  textsubjects = {
    enable = true,
    keymaps = {
      ['<cr>'] = 'textsubjects-smart', -- works in visual mode
    },
  },

  rainbow = {
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  },
})
