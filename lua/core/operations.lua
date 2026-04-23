local M = {}

local Terminal = require("toggleterm.terminal").Terminal

local function current_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil
  end

  return path
end

function M.make_root()
  local path = current_path()
  if not path then
    return nil
  end

  return vim.fs.root(path, "Makefile")
end

function M.run_in_float(cmd, dir)
  local term = Terminal:new({
    cmd = cmd,
    dir = dir,
    direction = "float",
    close_on_exit = false,
    hidden = true,
  })

  term:toggle()
end

function M.add_make_mapping()
  if not M.make_root() then
    return
  end

  vim.keymap.set("n", "<leader>om", function()
    local root = M.make_root()
    if not root then
      vim.notify("No Makefile found for current buffer", vim.log.levels.WARN)
      return
    end

    M.run_in_float("make", root)
  end, { buffer = true, desc = "Make" })
end

return M
