return {
  "xiyaowong/transparent.nvim",
  event = "VeryLazy",
  cmd = { "TransparentToggle", "TransparentEnable", "TransparentDisable" },
  -- keys = { "<leader>u", "<cmd>TransparentToggle<CR>", desc = "Toggle transparent" },
  keys = { "<leader>uo", "<cmd>TransparentToggle<CR>", desc = "Toggle opacity" },
  config = function()
    vim.keymap.set("n", "<leader>uo", "<cmd>TransparentToggle<CR>", { desc = "Toggle opacity" })

    require("transparent").setup({
      groups = { -- table: default groups
        "Normal",
        "NormalNC",
        "Comment",
        "Constant",
        "Special",
        "Identifier",
        "Statement",
        "PreProc",
        "Type",
        "Underlined",
        "Todo",
        "String",
        "Function",
        "Conditional",
        "Repeat",
        "Operator",
        "Structure",
        "LineNr",
        "NonText",
        "SignColumn",
        "CursorLine",
        "CursorLineNr",
        "StatusLine",
        "StatusLineNC",
        "EndOfBuffer",
      },
      extra_groups = { -- table: additional groups that should be cleared
        "NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
        "FloatBorder",
        "NvimTreeWinSeparator",
        "NvimTreeNormal",
        "NvimTreeNormalNC",
        "TroubleNormal",
        "TelescopeNormal",
        "TelescopeBorder",
        "WhichKeyFloat",
      },
    })
  end,
}
