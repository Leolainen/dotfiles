-- Window width based on the offset from the center, i.e. center window
-- is 60, then next over is 20, then the rest are 10.
-- Can use more resolution if you want like { 60, 20, 20, 10, 5 }
local widths = { 60, 20, 10 }

local ensure_center_layout = function(ev)
  local state = MiniFiles.get_explorer_state()
  if state == nil then
    return
  end

  -- Compute "depth offset" - how many windows are between this and focused
  local path_this = vim.api.nvim_buf_get_name(ev.data.buf_id):match("^minifiles://%d+/(.*)$")
  local depth_this
  for i, path in ipairs(state.branch) do
    if path == path_this then
      depth_this = i
    end
  end
  if depth_this == nil then
    return
  end
  local depth_offset = depth_this - state.depth_focus

  -- Adjust config of this event's window
  local i = math.abs(depth_offset) + 1
  local win_config = vim.api.nvim_win_get_config(ev.data.win_id)
  win_config.width = i <= #widths and widths[i] or widths[#widths]

  win_config.col = math.floor(0.5 * (vim.o.columns - widths[1]))
  for j = 1, math.abs(depth_offset) do
    local sign = depth_offset == 0 and 0 or (depth_offset > 0 and 1 or -1)
    -- widths[j+1] for the negative case because we don't want to add the center window's width
    local prev_win_width = (sign == -1 and widths[j + 1]) or widths[j] or widths[#widths]
    -- Add an extra +2 each step to account for the border width
    win_config.col = win_config.col + sign * (prev_win_width + 2)
  end

  win_config.height = depth_offset == 0 and 25 or 20
  win_config.row = math.floor(0.5 * (vim.o.lines - win_config.height))
  win_config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
  vim.api.nvim_win_set_config(ev.data.win_id, win_config)
end

vim.api.nvim_create_autocmd("User", { pattern = "MiniFilesWindowUpdate", callback = ensure_center_layout })

return {
  "nvim-mini/mini.files",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("mini.files").setup()

    vim.keymap.set("n", "<leader>e", "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>", { desc = "Explorer" })

    local set_mark = function(id, path, desc)
      MiniFiles.set_bookmark(id, path, { desc = desc })
    end

    local copy_path_to_clipboard = function()
      local path = MiniFiles.get_fs_entry().path
      print("Copying path to clipboard: " .. path)
      vim.fn.setreg("+", path)
    end

    local open_file_in_split = function(cmd)
      local cur_target_window = MiniFiles.get_explorer_state().target_window
      local new_target_window

      if cur_target_window ~= nil then
        vim.api.nvim_win_call(cur_target_window, function()
          vim.cmd("belowright " .. cmd .. " split")
          new_target_window = vim.api.nvim_get_current_win()
        end)

        MiniFiles.set_target_window(new_target_window)
        MiniFiles.go_in({ close_on_file = true })
      end

      MiniFiles.close()
    end

    local lastBuffer = nil

    vim.api.nvim_create_autocmd("BufLeave", {
      pattern = "MiniFilesExplorerOpen",
      callback = function()
        lastBuffer = vim.api.nvim_get_current_buf()
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local current_buf_id = args.data.buf_id
        local buf_id = lastBuffer

        if not buf_id then
          buf_id = current_buf_id
        end

        vim.keymap.set("n", "<S-Y>", copy_path_to_clipboard, { buffer = current_buf_id })
        vim.keymap.set("n", "<C-v>", function()
          open_file_in_split("vertical")
        end, { buffer = buf_id })
        vim.keymap.set("n", "<C-x>", function()
          open_file_in_split("horizontal")
        end, { buffer = buf_id })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesExplorerOpen",
      callback = function()
        -- set_mark('a', vim.fn.stdpath('config'), 'Config') -- path
        -- set_mark('w', vim.fn.getcwd, 'Working directory') -- callable
        set_mark("~", "~", "Home")
        set_mark("a", "~/ATG/atgse", "ATG SE")
        set_mark("d", "~/ATG/design-system", "Design system")
        set_mark("t", "~/ATG/atgse/libs/ui/toolkit", "Toolkit")
      end,
    })
  end,
}
