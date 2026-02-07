return {
  "github/copilot.vim",
  event = "BufRead",
  config = function()
    vim.keymap.set("i", "<C-h>", "<Plug>(copilot-dismiss)")
    vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)")
    vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)")
    vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-line)")
    vim.keymap.set("i", "<C-L>", "<Plug>(copilot-accept-word)")
    vim.keymap.set("i", "<C-J>", "<Plug>(copilot-suggest)")

    -- Mapping tab is already used by NvChad
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ""
    -- The mapping is set to other key, see custom/lua/mappings
    -- or run <leader>ch to see copilot mapping section
  end,
}
