-- File: lua/core/keymaps.lua
local conform = require("conform")
local map = vim.keymap.set

local function gmap(prefix, maps)
  for k, v in pairs(maps) do
    map("n", prefix .. k, v[1], { desc = v[2] })
  end
end

-- Set leader key before anything else
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local leader = "<leader>"
map('n', leader .. 'e', ':NvimTreeToggle<CR>', {
  desc = 'Toggle file explorer',
  silent = true,
  noremap = true
})
map('t', leader .. leader, '<Cmd>ToggleTerm<CR>', {
  noremap = true,
  silent = true,
  desc = "Toggle terminal"
})
-- Group Headers

local group_map = {
  m = { ":Mason<cr>", "LSP Mason" },
  d = { "<Nop>", "Diagnostics" },
  f = {
    function()
      conform.format({
        async = false,
        lsp_format = "fallback",
        timeout_ms = 1000,
      })
    end,
    "Format"
  },
  c = { "<Nop>", "Code" },
  g = { "<Nop>", "Git" },
  q = { "<Nop>", "Sessions" },
  x = { "<Nop>", "Trouble" },
  ["<leader>"] = { ":ToggleTerm<cr>", "Terminal" },
  ["<Tab>"] = { "<Nop>", "Tabs" },
  l = { "<Nop>", "Latex" }
}
local latex_map = {
  c = { ":VimtexCompile<cr>", "Compile" }
}
gmap(leader .. "l", latex_map)
gmap(leader, group_map)

-- Diagnostics
local diag_map = {
  l = { function() vim.diagnostic.open_float() end, "Line Diagnostic" },
  n = { function() vim.diagnostic.goto_next() end, "Next Diagnostic" }
}
gmap(leader .. "d", diag_map)

-- Code
map("n", "<leader>c", "<Nop>", { desc = "Code" })
local code_leader = leader .. "c"
local code_map = {
  c = { function() vim.o.conceallevel = (vim.o.conceallevel == 0) and 2 or 0 end, "Toggle Conceal" },
  s = { function() vim.lsp.buf.signature_help() end, "Signature Help" },
  d = { function() vim.lsp.buf.definition() end, "Definition" },
  r = { function() vim.lsp.buf.references() end, "References" },
  a = { function() vim.lsp.buf.code_action() end, "Actions" },
  i = { function() vim.lsp.buf.incoming_calls() end, "Incoming Calls" },
  n = { function() vim.lsp.buf.rename() end, "Rename" },
}
gmap(code_leader, code_map)


-- Tab
local tab_leader = leader .. "<Tab>"
local tab_map = {
  ["<Tab>"] = { ":tabnew<CR>", "New Tab" },
  n = { ":tabnext<CR>", "Next Tab" },
  p = { ":tabprevious<CR>", "Previous Tab" },
  f = { ":tabnew | enew<CR>", "New File" }
}
gmap(tab_leader, tab_map)

-- Github
local github_leader = leader .. "g"
local git_map = {
  ["rh"] = { ":Gitsigns reset_hunk<CR>", "Reset hunk" },
  ["rb"] = { ":Gitsigns reset_buffer<CR>", "Reset buffer" }
}
gmap(github_leader, git_map)

-- load the session for the current directory
vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Load Session" })

-- select a session to load
vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end, { desc = "Select Session" })

-- load the last session
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Load Last Session" })

-- stop Persistence => session won't be saved on exit
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Stop Session Saving" })
