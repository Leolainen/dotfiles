local function get_color(hl, attr, default)
  -- local color = hl and hl[attr] and string.format("0xff%06x", hl[attr]) or default
  local color = hl and hl[attr] and string.format("#%06x", hl[attr]) or default

  return color
end

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

-- Generates a ghostty theme from the current colorscheme
local function generate_ghostty_theme(colorscheme_name)
  local hl_groups = vim.api.nvim_get_hl(0, {})

  local palette = {
    get_color(hl_groups.Normal, "bg", "#24211E"), -- BLACK (Background)
    get_color(hl_groups.Statement, "fg", "#B3664D"), -- MAROON (Keywords)
    get_color(hl_groups.String, "fg", "#5F865F"), -- GREEN (Strings)
    get_color(hl_groups.PreProc, "fg", "#77824A"), -- OLIVE (Preprocessor)
    get_color(hl_groups.Function, "fg", "#B36B42"), -- NAVY (Functions)
    get_color(hl_groups.Keyword, "fg", "#BB7844"), -- PURPLE (Control Flow)
    get_color(hl_groups.Type, "fg", "#C9A654"), -- TEAL (Types)
    get_color(hl_groups.Normal, "fg", "#D7C484"), -- SILVER (Normal text)
    get_color(hl_groups.Comment, "fg", "#675642"), -- GREY (Comments)
    get_color(hl_groups.Error, "fg", "#AC987D"), -- RED (Errors)
    get_color(hl_groups.Special, "fg", "#5F865F"), -- LIME (Special symbols)
    get_color(hl_groups.Todo, "fg", "#77824A"), -- YELLOW (TODO comments)
    get_color(hl_groups.Identifier, "fg", "#B36B42"), -- BLUE (Identifiers)
    get_color(hl_groups.Constant, "fg", "#BB7844"), -- FUCHSIA (Constants)
    get_color(hl_groups.Operator, "fg", "#C9A654"), -- AQUA (Operators)
    get_color(hl_groups.Cursor, "bg", "#D7C484"), -- WHITE (Cursor)
  }

  local bg = get_color(hl_groups.Normal, "bg", "#24211E")
  local fg = get_color(hl_groups.Normal, "fg", "#d7c484")
  local cursor = get_color(hl_groups.Cursor, "bg", "#D7C484")
  local selection_fg = bg
  local selection_bg = get_color(hl_groups.Visual, "bg", "#77824A")

  print("cursor", cursor)
  local config = "# Auto-generated from Neovim colorscheme\n"
  config = config .. "background = " .. bg .. "\n"
  config = config .. "foreground = " .. fg .. "\n"
  config = config .. "cursor-color = " .. cursor .. "\n"
  config = config .. "selection-foreground = " .. selection_fg .. "\n"
  config = config .. "selection-background = " .. selection_bg .. "\n"

  for i, color in ipairs(palette) do
    config = config .. "palette = " .. i - 1 .. "=" .. color .. "\n"
  end

  -- Save to file
  local file = io.open(vim.fn.expand("~/.config/ghostty/themes/" .. colorscheme_name), "w")
  file:write(config)
  file:close()

  -- config = config .. "export palette=(" .. table.concat(palette, " ") .. ")\n"
  -- config = config .. "export background=" .. bg .. "\n"
  -- config = config .. "export foreground=" .. fg .. "\n"
  -- config = config .. "export cursor_color=" .. cursor .. "\n"
  -- config = config .. "export selection_foreground=" .. selection_fg .. "\n"
  -- config = config .. "export selection_background=" .. selection_bg .. "\n\n"
  --
  -- -- Named palette assignments
  -- local names = {
  --   "BLACK",
  --   "MAROON",
  --   "GREEN",
  --   "OLIVE",
  --   "NAVY",
  --   "PURPLE",
  --   "TEAL",
  --   "SILVER",
  --   "GREY",
  --   "RED",
  --   "LIME",
  --   "YELLOW",
  --   "BLUE",
  --   "FUCHSIA",
  --   "AQUA",
  --   "WHITE",
  -- }
  --
  -- for i, name in ipairs(names) do
  --   config = config .. ('export %s="${palette[%d]}"\n'):format(name, i - 1)
  -- end
  --
  -- -- Save to file
  -- local file = io.open(vim.fn.expand("~/.config/sketchybar/colors.sh"), "w")
  -- file:write(config)
  -- file:close()
  --
  -- print("Sketchybar colors generated from Neovim!")
end

local function update_theme_in_ghostty(colorscheme_name)
  local ghostty_path = vim.fn.expand("~/.config/ghostty/config")
  local found_line = false
  local line_num = 0
  local lines = {}

  local ghostty_config = io.open(ghostty_path, "r")

  if ghostty_config then -- Check if file opened successfully
    for line in ghostty_config:lines() do
      if not found_line then
        line_num = line_num + 1
      end
      table.insert(lines, line)

      if string.match(line, "theme = ") then
        found_line = true
      end
    end

    ghostty_config:close()
  else
    print("Error: Could not open " .. ghostty_path .. " for reading. File might not exist.")
    return -- Prevent writing if reading failed
  end

  lines[line_num] = "theme = " .. colorscheme_name .. "\n"

  -- Update the theme line or append if not found
  if found_line then
    lines[line_num] = "theme = " .. colorscheme_name
  else
    table.insert(lines, "theme = " .. colorscheme_name) -- Append if no existing theme line
  end

  ghostty_config = io.open(ghostty_path, "w")

  if ghostty_config then
    for _, line in ipairs(lines) do
      ghostty_config:write(line .. "\n")
    end
    ghostty_config:close()
  else
    print("Error: Could not open " .. ghostty_path .. " for writing.")
  end
end

local function get_nearest_packagejson()
  local cwd = vim.fn["getcwd"]()
  -- local path = cwd
  -- local found = false

  local markers = { "package.json", ".git" }
  local root_dir = vim.fs.root(cwd, markers)

  -- while not found do
  --   if vim.fn.filereadable(path .. "/package.json") == 1 then
  --     found = true
  --   else
  --
  --   else
  --     path = vim.fn.fnamemodify(path, ":h")
  --   end
  -- end

  -- return path
  return root_dir
end

local function git_root_path()
  local result = vim.fn.systemlist("git rev-parse --show-toplevel")

  if not result[1] then
    vim.print("Error: Could not determine Git root!")
  end

  return result[1] or LazyVim.root() -- Avoid indexing nil if Git fails
end

local snacks = require("snacks")

return {
  "folke/snacks.nvim",
  opts = {
    -- turn off animated scrolling
    scroll = { enabled = false },
  },
  keys = {
    {
      "<leader>ff",
      function()
        snacks.picker.files({ cwd = LazyVim.root(), cmd = "rg", dirs = { get_nearest_packagejson() } })
      end,
      desc = "Find files (cwd)",
    },
    {
      "<leader>fF",
      function()
        snacks.picker.files({ cwd = git_root_path(), cmd = "rg" })
      end,
      desc = "Find files (root)",
    },
    {
      "<leader>sg",
      function()
        snacks.picker.grep({ cwd = LazyVim.root(), cmd = "rg", dirs = { get_nearest_packagejson() } })
      end,
      desc = "grep (cwd)",
    },
    {
      "<leader>sG",
      function()
        snacks.picker.grep({ cwd = git_root_path(), cmd = "rg" })
      end,
      desc = "grep (root)",
    },
    {
      "<leader>fg",
      function()
        local cwd = git_root_path()

        local handle = io.popen("git -C " .. cwd .. " ls-files -m")
        local items = {}

        if handle then
          local i = 1
          for file in handle:lines() do
            table.insert(items, {
              idx = i,
              score = i,
              text = file,
              file = cwd .. "/" .. file,
            })

            i = i + 1
          end

          handle:close()
        end

        Snacks.picker({
          items = items,
          cwd = cwd,
        })
      end,
      desc = "Find changed files (git)",
    },
    {
      "<leader>fp",
      function()
        snacks.picker.projects({
          max_depth = 8,
          dev = { "~/ATG/atgse", "~/ATG/design-system" },
          patterns = { "package.json", "init.lua" },
          -- patterns = { ".git", "package.json", "project.json", "init.lua" },
          confirm = function(picker, item)
            if item then
              Snacks.picker.files({ dirs = { item.text } })
            end
          end,
          matcher = {
            frecency = true, -- use frecency boosting
            sort_empty = true, -- sort even when the filter is empty
            cwd_bonus = false,
          },
          recent = true,
        })
      end,
      desc = "Projects",
    },
    {
      "<leader>uC",
      function()
        require("snacks").picker.colorschemes({
          finder = "vim_colorschemes",
          format = "text",
          preview = "colorscheme",
          preset = "vertical",
          confirm = function(picker, item)
            picker:close()
            if item then
              picker.preview.state.colorscheme = nil
              vim.schedule(function()
                vim.cmd("colorscheme " .. item.text)

                if
                  not file_exists(vim.fn.expand("~/.config/ghostty/themes/" .. item.text))
                  and not file_exists(
                    vim.fn.expand("/Applications/Ghostty.app/Contents/Resources/ghostty/themes/" .. item.text)
                  )
                then
                  generate_ghostty_theme(item.text)
                end

                update_theme_in_ghostty(item.text)

                -- Reload Ghostty
                local reload_ghostty = [[
                    osascript -e '
                    tell application "System Events"
                        tell process "Ghostty"
                            click menu item "Reload Configuration" of menu "Ghostty" of menu bar item "Ghostty" of menu bar 1
                        end tell
                    end tell'
                ]]

                local reload_sketchybar = "brew services restart sketchybar"

                os.execute(reload_ghostty)
                os.execute(reload_sketchybar)
              end)
            end
          end,
        })
      end,
      desc = "Colorschemes",
    },
  },
}
