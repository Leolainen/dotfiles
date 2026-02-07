-- Included in LazyExtras
-- stylua: ignore
if true then return {} end

-- return {
--   "nvim-treesitter/nvim-treesitter-context",
--   event = { "BufRead" },
--   config = function()
--     require("treesitter-context").setup({
--       mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
--       -- Separator between context and content. Should be a single character string, like '-'.
--       -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
--       separator = "–",
--       -- How many lines the window should span. Values <= 0 mean no limit.
--       max_lines = 4,
--     })
--   end,
-- }
