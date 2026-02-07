return {
  "esmuellert/nvim-eslint",
  event = "VeryLazy",
  opts = function()
    local opts = {
      root_dir = function(bufnr)
        return require("nvim-eslint").resolve_package_json_dir(bufnr)
      end,
      handlers = {
        -- get notified if the config file failed to load
        ["eslint/noConfig"] = function(_, result)
          vim.notify(result.message, vim.log.levels.WARN)
          return {}
        end,
      },
      settings = {
        workingDirectory = function(bufnr)
          return { directory = vim.fs.root(bufnr, { "package.json" }) }
        end,
      },
    }

    return opts
  end,
  config = function(_, opts)
    require("nvim-eslint").setup(opts)
  end,
}
