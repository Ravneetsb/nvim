require('mini.surround').setup()
require('mini.animate').setup()
require('mini.indentscope').setup()
-- require('mini.notify').setup()
require('mini.completion').setup()
require('mini.pairs').setup()

local luasnip = require("luasnip")

vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  end
  if luasnip.expand_or_jumpable() then
    return "<Plug>luasnip-expand-or-jump"
  end
  return "<Tab>"
end, { expr = true, silent = true, desc = "Snippet Expand or Jump" })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  end
  if luasnip.jumpable(-1) then
    return "<Plug>luasnip-jump-prev"
  end
  return "<S-Tab>"
end, { expr = true, silent = true, desc = "Snippet Jump Back" })
