local function prettier()
	return {
		exe = "prettier",
		args = {
			"--config-precedence",
			"prefer-file",
			"--single-quote",
			"--no-bracket-spacing",
			"--prose-wrap",
			"always",
			"--arrow-parens",
			"always",
			"--trailing-comma",
			"all",
			"--no-semi",
			"--end-of-line",
			"lf",
			"--print-width",
			vim.bo.textwidth <= 80 and 80 or vim.bo.textwidth,
			"--stdin-filepath",
			vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
		},
		stdin = true,
	}
end

local function shfmt()
	return {
		exe = "shfmt",
		args = { "-" },
		stdin = true,
	}
end

local filetype = {
	javascript = { prettier },
	typescript = { prettier },
	javascriptreact = { prettier },
	typescriptreact = { prettier },
	vue = { prettier },
	["javascript.jsx"] = { prettier },
	["typescript.tsx"] = { prettier },
	markdown = { prettier },
	["markdown.mdx"] = { prettier },
	mdx = { prettier },
	css = { prettier },
	json = { prettier },
	jsonc = { prettier },
	scss = { prettier },
	less = { prettier },
	yaml = { prettier },
	graphql = { prettier },
	html = { prettier },
	sh = { shfmt },
	bash = { shfmt },
	reason = {
		function()
			return {
				exe = "refmt",
				stdin = true,
			}
		end,
	},
	rust = {
		function()
			return {
				exe = "rustfmt",
				args = { "--emit=stdout" },
				stdin = true,
			}
		end,
	},
	python = {
		function()
			return {
				exe = "black",
				args = { "--quiet", "-" },
				stdin = true,
			}
		end,
	},
	go = {
		function()
			-- this will run gofmt too
			return {
				exe = "goimports",
				args = { "-w", vim.api.nvim_buf_get_name(0) },
				stdin = false,
			}
		end,
	},
	nix = {
		function()
			return {
				exe = "nixpkgs-fmt",
				stdin = true,
			}
		end,
		function()
			return {
				exe = "statix fix --stdin",
				stdin = true,
			}
		end,
	},
	lua = {
		function()
			return {
				exe = "stylua",
				args = {
					"--indent-type",
					"Spaces",
					"--line-endings",
					"Unix",
					"--quote-style",
					"AutoPreferSingle",
					"--indent-width",
					vim.bo.tabstop,
					"--column-width",
					vim.bo.textwidth,
					"-",
				},
				stdin = true,
			}
		end,
	},
	-- Use the special "*" filetype for defining formatter configurations on any filetype
	["*"] = {
		function()
			return { exe = "sed", args = { "-i", "''", "'s/[	 ]*$//'" } }
		end,
	},
}

-- Provides the Format and FormatWrite commands
require("formatter").setup({
	-- Enable or disable logging
	logging = false,
	-- All formatter configurations are opt-in
	filetype = filetype,
})

--   -- Utilities for creating configurations
--   local util = require "formatter.util"

--   -- Provides the Format and FormatWrite commands
--   require("formatter").setup {
--     -- Enable or disable logging
--     logging = true,
--     -- Set the log level
--     log_level = vim.log.levels.WARN,
--     -- All formatter configurations are opt-in
--     filetype = {
--       -- Formatter configurations for filetype "lua" go here
--       -- and will be executed in order
--       lua = {
--         -- "formatter.filetypes.lua" defines default configurations for the
--         -- "lua" filetype
--         require("formatter.filetypes.lua").stylua,

--         -- You can also define your own configuration
--         function()
--           -- Supports conditional formatting
--           if util.get_current_buffer_file_name() == "special.lua" then
--             return nil
--           end

--           -- Full specification of configurations is down below and in Vim help
--           -- files
--           return {
--             exe = "stylua",
--             args = {
--               "--search-parent-directories",
--               "--stdin-filepath",
--               util.escape_path(util.get_current_buffer_file_path()),
--               "--",
--               "-",
--             },
--             stdin = true,
--           }
--         end
--       },

--       -- Use the special "*" filetype for defining formatter configurations on
--       -- any filetype
--       ["*"] = {
--         -- "formatter.filetypes.any" defines default configurations for any
--         -- filetype
--         require("formatter.filetypes.any").remove_trailing_whitespace
--       }
--     }
--   }
