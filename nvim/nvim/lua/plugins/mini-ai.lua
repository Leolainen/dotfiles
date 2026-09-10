return {
  "nvim-mini/mini.ai",
  event = "VeryLazy",
  version = "*",
  config = function()
    require("mini.ai").setup({
      search_method = "cover",
      -- Unsets default textobject mappings. They work poorly in .tsx files
      mappings = {
        around = "",
        inside = "",
        around_next = "",
        inside_next = "",
        around_last = "",
        inside_last = "",
        goto_left = "",
        goto_right = "",
      },
      custom_textobjects = {
        e = {
          {
            "[^_%-]()[_%-]+()%w()()[%s%p]",
            "^()[_%-]+()%w()()[%s%p]",
            "[^_%-]()[_%-]+()%d+%u[%u%d]+()()",
            "^()[_%-]+()%d+%u[%u%d]+()()",
            "[^_%-]()[_%-]+()%d+%l[%l%d]+()()",
            "^()[_%-]+()%d+%l[%l%d]+()()",
            "[^_%-]()[_%-]+()%u[%u%d]+()()",
            "^()[_%-]+()%u[%u%d]+()()",
            "[^_%-]()[_%-]+()%a[%l%d]+()()",
            "^()[_%-]+()%a[%l%d]+()()",
            "[^_%-%u]()()%u[%u%d]+()[_%-]*()",
            "^()()%u[%u%d]+()[_%-]*()",
            "%u%u()()[%l%d]+()[_%-]*()",
            "[^_%-%w]()()[%l%d]+()[_%-]*()",
            "^()()[%l%d]+()[_%-]*()",
            "[^_%-%u]()()%u[%l%d]+()[_%-]*()",
            "^()()%u[%l%d]+()[_%-]*()",
          },
        },
      },
    })

    local ai = require("mini.ai")

    -- Manually create only the e-related mappings
    vim.keymap.set({ "x", "o" }, "ae", function()
      ai.select_textobject("a", "e")
    end, { desc = "around subword" })

    vim.keymap.set({ "x", "o" }, "ie", function()
      ai.select_textobject("i", "e")
    end, { desc = "inside subword" })
  end,
}
