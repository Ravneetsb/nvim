require("mason-lspconfig").setup {
  automatic_enable = {
    exclude = {
      "rust_analyzer",
    }
  }
}
-- vim.lsp.enable("basedpyright")
-- vim.lsp.enable("lua_ls")
-- vim.lsp.enable("rust_analyzer")
-- vim.lsp.enable("clangd")
-- vim.lsp.enable("jdtls")
-- vim.lsp.enable("haskell-language-server")
-- vim.lsp.enable("elmls")
-- vim.lsp.enable("purescriptls")
-- vim.lsp.enable("ts_ls")
-- vim.lsp.enable("html")
-- vim.lsp.enable("cssls")
-- vim.lsp.enable("taplo")
-- vim.lsp.config("ltex-ls", {
--   cmd = { "ltex-ls" },
--   filetypes = { "tex", "markdown", "text" },
--   settings = {
--     ltex = {
--       language = "en-US",
--       additionalRules = {
--         motherTongue = "en",
--       },
--     },
--   },
-- })
-- vim.lsp.enable("ltex-ls", {
--   cmd = { vim.fn.stdpath("data") .. "/mason/bin/ltex-ls" },
--   filetypes = { "tex", "markdown", "text" },
--   settings = {
--     ltex = {
--       language = "en-US",
--     },
--   },
-- })
