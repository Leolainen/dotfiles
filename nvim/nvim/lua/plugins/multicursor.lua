-- local status_ok, mc = pcall(require, "multicursor-nvim")
--
-- if not status_ok then
--   print("Multicursor could not load")
--   return
-- end

return {
  "jake-stewart/multicursor.nvim",
  event = "VeryLazy",
  branch = "1.0",
  opts = {},
  keys = {
    {
      "<esc>",
      function()
        local mc = require("multicursor-nvim")
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        elseif mc.hasCursors() then
          mc.clearCursors()
        else
          -- Default <esc> handler.
        end
      end,
    },
  },
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()
    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set({ "n", "v" }, "º", function()
      mc.lineAddCursor(-1)
    end)
    set({ "n", "v" }, "¬", function()
      mc.lineAddCursor(1)
    end)

    -- Add or skip adding a new cursor by matching word/selection
    set({ "n", "v" }, "<C-n>", function()
      mc.matchAddCursor(1)
    end, {
      desc = "Add cursor to matching word/selection",
    })
    set({ "n", "v" }, "<C-m>", mc.deleteCursor)
    -- set({ "n", "v" }, "<C-J>",
    --     function() mc.matchSkipCursor(1) end)
    -- set({ "n", "v" }, "<C-K>",
    --     function() mc.matchSkipCursor(-1) end)

    set("n", "<esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        -- Default <esc> handler.
      end
    end)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { link = "Cursor" })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end,
}
