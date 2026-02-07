return {
  "rmagatti/goto-preview",
  event = "VeryLazy",
  keys = { "gpd", "gpt" },
  config = function()
    local gtp = require("goto-preview")
    local select_to_edit_map = {
      default = "edit",
      up = "topleft split",
      right = "vert botright split",
      down = "botright split",
      left = "vert topleft split",
      next = "wincmd w",
      previous = "wincmd W",
    }

    -- new stuff
    local original_keymaps = {}
    local open_previews = {}

    local function store_original_keymaps(buf)
      local maps = vim.api.nvim_buf_get_keymap(0, "")
      -- local maps = vim.keymap.get('', { buffer = buf })
      original_keymaps[buf] = {}

      for _, m in ipairs(maps) do
        table.insert(original_keymaps[buf], {
          mode = m.mode,
          lhs = m.lhs,
          rhs = m.rhs,
          silent = m.silent,
          expr = m.expr,
          noremap = m.noremap,
          nowait = m.nowait,
        })
      end
    end

    local function restore_original_keymaps(buf)
      local maps = original_keymaps[buf] or {}

      for _, m in ipairs(maps) do
        vim.api.nvim_buf_set_keymap(buf, m.mode, m.lhs, m.rhs, {
          silent = m.silent,
          expr = m.expr,
          noremap = m.noremap,
          nowait = m.nowait,
        })
      end
    end

    function _G.restore_keybindings_on_floating_window_close()
      local floating_windows = vim.tbl_filter(function(w)
        return vim.api.nvim_win_get_config(w).relative ~= ""
      end, vim.api.nvim_tabpage_list_wins(0))

      for _, win in ipairs(floating_windows) do
        -- picks buffer from opened preview windows
        local buf = open_previews[win]

        -- if it exists, try to restore original key bindings
        if buf then
          restore_original_keymaps(buf)
          -- remove preview window from list
          open_previews[win] = nil
        end
      end
    end

    local function open_file(orig_window, filename, cursor_position, command)
      if orig_window ~= 0 and orig_window ~= nil then
        vim.api.nvim_set_current_win(orig_window)
      end

      pcall(function()
        vim.cmd(string.format("%s %s", command, filename))
      end)
      vim.api.nvim_win_set_cursor(0, cursor_position)
    end

    local function open_preview(preview_win, type)
      return function()
        local command = select_to_edit_map[type]
        local orig_window = vim.api.nvim_win_get_config(preview_win).win
        local cursor_position = vim.api.nvim_win_get_cursor(preview_win)
        local filename = vim.api.nvim_buf_get_name(0)

        vim.api.nvim_win_close(preview_win, gtp.conf.force_close)
        open_file(orig_window, filename, cursor_position, command)

        local buffer = vim.api.nvim_get_current_buf()
        store_original_keymaps(buffer)

        vim.api.nvim_buf_del_keymap(buffer, "n", "<C-w>l")
        vim.api.nvim_buf_del_keymap(buffer, "n", "<C-w>k")
        vim.api.nvim_buf_del_keymap(buffer, "n", "<C-w>j")
        vim.api.nvim_buf_del_keymap(buffer, "n", "<C-w>h")
        vim.api.nvim_buf_del_keymap(buffer, "n", "<CR>")
        -- vim.api.nvim_buf_del_keymap(buffer, 'n', '<S-L>')
        -- vim.api.nvim_buf_del_keymap(buffer, 'n', '<S-H>')

        -- stores buffer in preview window id list
        open_previews[preview_win] = buffer
      end
    end

    -- local function cycle_preview(direction)
    --   return function()
    --     local all_windows = vim.api.nvim_tabpage_list_wins(0)
    --     local current_window = vim.api.nvim_get_current_win()
    --
    --     for i = 1, #all_windows do
    --       local j = (i + direction - 1) % #all_windows + 1
    --       local win = all_windows[j]
    --
    --       if vim.api.nvim_win_get_config(win).relative ~= "" and win ~= current_window then
    --         vim.api.nvim_set_current_win(win)
    --         break
    --       end
    --     end
    --   end
    -- end

    local function post_open_hook(buf, win)
      -- local current_buf = vim.api.nvim_get_current_buf()
      vim.keymap.set("n", "<C-w>l", open_preview(win, "right"), { buffer = buf })
      vim.keymap.set("n", "<C-w>k", open_preview(win, "up"), { buffer = buf })
      vim.keymap.set("n", "<C-w>j", open_preview(win, "down"), { buffer = buf })
      vim.keymap.set("n", "<C-w>h", open_preview(win, "left"), { buffer = buf })
      vim.keymap.set("n", "<CR>", open_preview(win, "default"), { buffer = buf })
      -- vim.keymap.set('n', '<S-L>', cycle_preview(1), { buffer = buf })
      -- vim.keymap.set('n', '<S-H>', cycle_preview(-1), { buffer = buf })
    end

    -- vim.cmd([[autocmd WinClosed * lua _G.restore_keybindings_on_floating_window_close()]])
    -- vim.cmd([[autocmd WinClosed * lua _G.restore_keybindings_on_floating_window_close()]])
    -- vim.cmd([[autocmd WinClosed * lua _G.restore_keybindings_on_floating_window_close()]])

    gtp.setup({
      default_mappings = true,
      post_open_hook = post_open_hook,
    })
  end,
}
