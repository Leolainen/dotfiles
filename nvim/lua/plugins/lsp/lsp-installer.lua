local status_ok, lsp_installer = pcall(require, 'nvim-lsp-installer')
if not status_ok then
  return
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = require('plugins.lsp.handlers').on_attach,
    capabilities = require('plugins.lsp.handlers').capabilities,
  }

  if server.name == 'jsonls' then
    local jsonls_opts = require('plugins.lsp.settings.jsonls')
    opts = vim.tbl_deep_extend('force', jsonls_opts, opts)
  end

  if server.name == 'sumneko_lua' then
    local sumneko_opts = require('plugins.lsp.settings.sumneko_lua')
    opts = vim.tbl_deep_extend('force', sumneko_opts, opts)
  end

  if server.name == 'tsserver' then
    local tsserver_opts = require('plugins.lsp.settings.tsserver')
    opts = vim.tbl_deep_extend('force', tsserver_opts, opts)
  end

  if server.name == 'eslint' then
    local eslint_opts = require('plugins.lsp.settings.eslint')
    opts = vim.tbl_deep_extend('force', eslint_opts, opts)
  end

  if server.name == 'bashls' then
    local bash_opts = require('plugins.lsp.settings.bashls')
    opts = vim.tbl_deep_extend('force', bash_opts, opts)
  end

  if server.name == 'cssls' then
    local css_opts = require('plugins.lsp.settings.cssls')
    opts = vim.tbl_deep_extend('force', css_opts, opts)
  end

  if server.name == 'graphql' then
    local graphql_opts = require('plugins.lsp.settings.graphql')
    opts = vim.tbl_deep_extend('force', graphql_opts, opts)
  end

  if server.name == 'html' then
    local html_opts = require('plugins.lsp.settings.html')
    opts = vim.tbl_deep_extend('force', html_opts, opts)
  end

  -- This setup() function is exactly the same as lspconfig's setup function.
  -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  server:setup(opts)
end)
