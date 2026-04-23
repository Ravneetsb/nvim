local operations = require("core.operations")

local function project_root()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil
  end

  return vim.fs.root(path, "go.mod")
end

local function run_go(cmd)
  local root = project_root()
  if not root then
    vim.notify("No go.mod found for current Go buffer", vim.log.levels.WARN)
    return
  end

  operations.run_in_float(cmd, root)
end

vim.keymap.set("n", "<leader>o", "<Nop>", { buffer = true, desc = "Operations" })
vim.keymap.set("n", "<leader>ob", function()
  run_go("go build")
end, { buffer = true, desc = "Build" })
vim.keymap.set("n", "<leader>ot", function()
  run_go("go test ./...")
end, { buffer = true, desc = "Test" })
operations.add_make_mapping()
