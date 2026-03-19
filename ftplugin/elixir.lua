local lspconfig = require("lspconfig")

lspconfig.elixirls.setup({
  cmd = { vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/language_server.sh" },
})

