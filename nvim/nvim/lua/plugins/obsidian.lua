return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  config = function()
    local obsidian = require("obsidian")

    obsidian.setup({
      picker = {
        name = "snacks.picker",
      },
      workspaces = {
        {
          name = "atg",
          path = "~/vaults/atg",
        },
      },
      opts = {
        legacy_commands = false, -- this will be removed in 4.0.0
      },
    })
  end,
}
