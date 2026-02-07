return {
  "nvim-mini/mini.move",
  -- event = { "BufRead", "BufNew", "BufEnter" },
  event = "VeryLazy",
  config = function()
    require("mini.move").setup({
      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = "˛",
        right = "ﬁ",
        down = "√",
        up = "ª",
        -- Move current line in Normal mode
        line_left = "<Nop>",
        line_right = "<Nop>ﬁ",
        line_down = "√",
        line_up = "ª",
      },
    })
  end,
}
