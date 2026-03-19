return {
  "Jxstxs/conceal.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local conceal = require("conceal")

    conceal.setup({
      ["lua"] = {
        enabled = true,
        keywords = {
          ["return"] = { conceal = "↩" },
        },
      },
      ["java"] = {
        enabled = true,
        keywords = {
          ["public"]    = { conceal = "⊞", capture = "public" },
          ["private"]   = { conceal = "⊟", capture = "private" },
          ["protected"] = { conceal = "⊡", capture = "protected" },
          ["class"]     = { conceal = "🏛", capture = "class_keyword" },
          ["static"]    = { conceal = "⚙", capture = "static" },
          ["return"]    = { conceal = "↩", capture = "return" },
          ["void"]      = { conceal = "∅", capture = "void" },
          ["new"]       = { conceal = "🆕", capture = "new" },
        },
      },
    })

    -- Generate Tree-sitter conceal queries (run once or after changes)
    pcall(conceal.generate_conceals)
    -- Toggle conceal.
  end,
}
