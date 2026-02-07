return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      {
        { "ö", group = "prev" },
        { "å", group = "next" },
      },
      { "<leader>a", group = "AI", mode = { "n", "v" } },
    },
  },
  keys = {
    {
      "<leader>gk",
      function()
        require("gitsigns").nav_hunk("next")
      end,
      desc = "Next Hunk",
    },
    {
      "<leader>gj",
      function()
        require("gitsigns").nav_hunk("prev")
      end,
      desc = "Prev Hunk",
    },
    -- R = { "<cmd>Gitsigns reset_buffer<cr>", "Reset Hunk" },
    -- r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk" },
    -- s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk" },
    -- j = { "<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>", "Next Hunk" },
    -- k = { "<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>", "Prev Hunk" },
    -- l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
  },
}
