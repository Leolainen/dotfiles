return {
  "lewis6991/gitsigns.nvim",
  enabled = true,
  -- keys = {
  --   {
  --     "<leader>gj",
  --     function()
  --       if vim.wo.diff then
  --         vim.cmd.normal({ "]c", bang = true })
  --       else
  --         require("gitsigns").nav_hunk("next")
  --       end
  --     end,
  --     -- end, "Next Hunk")
  --   },
  --   {
  --     "<leader>gk",
  --     function()
  --       if vim.wo.diff then
  --         vim.cmd.normal({ "[c", bang = true })
  --       else
  --         require("gitsigns").nav_hunk("prev")
  --       end
  --     end,
  --     -- end, "Prev Hunk")
  --   },
  --   {},
  -- },
}

-- R = { "<cmd>Gitsigns reset_buffer<cr>", "Reset Hunk" },
-- r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk" },
-- s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk" },
-- j = { "<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>", "Next Hunk" },
-- k = { "<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>", "Prev Hunk" },
-- l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
