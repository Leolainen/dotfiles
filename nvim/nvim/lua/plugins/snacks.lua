local plugin_file = vim.uv.fs_realpath(debug.getinfo(1, "S").source:sub(2))
local theme_cli = vim.fn.fnamemodify(plugin_file, ":h:h:h:h:h") .. "/scripts/dotfiles-theme"

local function apply_theme(name)
  local function color(group, attr, fallback)
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false, create = false })
    return hl[attr] and string.format("#%06x", hl[attr]) or fallback
  end

  local palette = {
    color("Normal", "bg", vim.o.background == "light" and "#ffffff" or "#24211E"), -- BLACK (Background)
    color("Statement", "fg", "#B3664D"), -- MAROON (Keywords)
    color("String", "fg", "#5F865F"), -- GREEN (Strings)
    color("PreProc", "fg", "#77824A"), -- OLIVE (Preprocessor)
    color("Function", "fg", "#B36B42"), -- NAVY (Functions)
    color("Keyword", "fg", "#BB7844"), -- PURPLE (Control Flow)
    color("Type", "fg", "#C9A654"), -- TEAL (Types)
    color("Normal", "fg", vim.o.background == "light" and "#24211E" or "#D7C484"), -- SILVER (Normal text)
    color("Comment", "fg", "#675642"), -- GREY (Comments)
    color("Error", "fg", "#AC987D"), -- RED (Errors)
    color("Special", "fg", "#5F865F"), -- LIME (Special symbols)
    color("Todo", "fg", "#77824A"), -- YELLOW (TODO comments)
    color("Identifier", "fg", "#B36B42"), -- BLUE (Identifiers)
    color("Constant", "fg", "#BB7844"), -- FUCHSIA (Constants)
    color("Operator", "fg", "#C9A654"), -- AQUA (Operators)
    color("Cursor", "bg", "#D7C484"), -- WHITE (Cursor)
  }

  local slug = name:lower():gsub("[^a-z0-9-]+", "-")
  local id = "nvim-" .. slug
  if slug ~= name then
    id = id .. "-" .. vim.fn.sha256(name):sub(1, 8)
  end

  local manifest = {
    id = id,
    name = name,
    source = { type = "neovim", colorscheme = name },
    appearance = vim.o.background,
    ansi = palette,
    colors = {
      background = palette[1],
      surface = color("NormalFloat", "bg", palette[1]),
      foreground = palette[8],
      muted = palette[9],
      accent = palette[5],
      selection = color("Visual", "bg", palette[4]),
      cursor = palette[16],
      border = color("FloatBorder", "fg", palette[9]),
      error = color("DiagnosticError", "fg", palette[10]),
      success = color("DiagnosticOk", "fg", palette[3]),
      warning = color("DiagnosticWarn", "fg", palette[12]),
    },
  }

  local cli = vim.fn.executable(theme_cli) == 1 and theme_cli or vim.fn.exepath("dotfiles-theme")
  if cli == "" then
    vim.notify("Cannot find dotfiles-theme to apply " .. name, vim.log.levels.WARN)
    return
  end

  local output = vim.fn.system({ cli, "import-neovim" }, vim.json.encode(manifest))
  if vim.v.shell_error == 0 then
    output = vim.fn.system({ cli, "apply", vim.trim(output) })
  end
  vim.notify(vim.trim(output), vim.v.shell_error == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
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
    explorer = { enabled = false },
  },
  keys = {
    -- Disable default file explorer mappings
    -- I use mini.files instead
    { "<leader>fe", false },
    { "<leader>fE", false },
    { "<leader>E", false },
    { "<leader>e", false },
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
          dev = { "~/ATG/atgse", "~/ATG/design-system", "~/Projects" },
          patterns = { "git.init", "package.json", "init.lua" },
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
                vim.cmd.colorscheme({ args = { item.text } })
                apply_theme(item.text)
              end)
            end
          end,
        })
      end,
      desc = "Colorschemes",
    },
  },
}
