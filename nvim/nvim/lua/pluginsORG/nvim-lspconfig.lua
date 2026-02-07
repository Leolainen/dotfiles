local nb_actions = {}

function nb_actions.grep(opts)
  local callback = function(display)
    vim.print(display.focus_node.parent.children)
    local status_ok, snacks = pcall(require, "snacks")

    if not status_ok then
      vim.notify("snacks not found", vim.log.levels.ERROR)
      return
    end

    local handle = io.popen("git -C " .. cwd .. " ls-files -m")
    local items = {}
    local children = display.focus_node.parent.children

    local i = 1
    for child in children do
      table.insert(items, {
        idx = i,
        score = i,
        text = child,
        -- file = cwd .. "/" .. file,
      })

      i = i + 1
    end

    -- snacks.picker.Config
    -- snacks.picker.picker("matcher",)
    snacks.picker.pick(display.focus_node.parent.children)
  end

  return {
    callback = callback,
    description = "Grep",
  }
end

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "SmiteshP/nvim-navbuddy",
      -- event = "VeryLazy",
      dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim",
      },
      cmd = "Navbuddy",
      keys = {
        {
          "<leader>bn",
          "<cmd>Navbuddy<cr>",
          desc = "Navbuddy",
        },
      },
      opts = {
        lsp = { auto_attach = true },
        mappings = {
          ["g"] = nb_actions.grep(),
          -- ["g"] = function()
          --   -- https://github.com/SmiteshP/nvim-navbuddy/blob/f22bac988f2dd073601d75ba39ea5636ab6e38cb/lua/nvim-navbuddy/actions.lua
          --   local callback = function(display)
          --     vim.notify("hello", vim.log.levels.ERROR)
          --     vim.print(display.focus_node.parent.children)
          --     -- local status_ok, _ = pcall(require, "snacks")
          --     --
          --     -- if not status_ok then
          --     --   vim.notify("snacks not found", vim.log.levels.ERROR)
          --     --   return
          --     -- end
          --
          --     -- display:close()
          --   end
          --
          --   return {
          --     callback = callback,
          --     description = "Fuzzy filter",
          --   }
          -- end,
        },
      },

      -- config = function() end,
    },
  },
  opts = {
    inlay_hints = { enabled = false },
  },

  -- config = function()
  --   vim.print("hello")
  --   vim.notify("hello", vim.log.levels.ERROR)
  --
  --   -- local navbuddy_ok, navbuddy = pcall(require, "nvim-navbuddy")
  --   -- if not navbuddy_ok then
  --   --   vim.notify("Navbuddy not found", vim.log.levels.ERROR)
  --   --   return
  --   -- end
  --
  --   -- require("nvim-navbuddy").setup({
  --   --   mappings = {
  --   --     ["t"] = function(opts)
  --   --       -- https://github.com/SmiteshP/nvim-navbuddy/blob/f22bac988f2dd073601d75ba39ea5636ab6e38cb/lua/nvim-navbuddy/actions.lua
  --   --       -- TODO: attempt to replace telescope with snacks
  --   --       local callback = function(display)
  --   --         local status_ok, _ = pcall(require, "snacks")
  --   --
  --   --         if not status_ok then
  --   --           vim.notify("snacks not found", vim.log.levels.ERROR)
  --   --           return
  --   --         end
  --   --       end
  --   --
  --   --       return {
  --   --         callback = callback,
  --   --         description = "Fuzzy filter",
  --   --       }
  --   --     end,
  --   --   },
  --   -- })
  -- end,
}
