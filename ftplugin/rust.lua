local dap = require("dap")
local Terminal = require("toggleterm.terminal").Terminal

local function project_root()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil
  end

  return vim.fs.root(path, "Cargo.toml")
end

local function run_cargo(cmd)
  local root = project_root()
  if not root then
    vim.notify("No Cargo.toml found for current Rust buffer", vim.log.levels.WARN)
    return
  end

  local term = Terminal:new({
    cmd = cmd,
    dir = root,
    direction = "float",
    close_on_exit = false,
    hidden = true,
  })

  term:toggle()
end

local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = { "--port", "${port}" },
    -- On Linux you may need:
    detached = false,
  }
}

dap.configurations.rust = {
  {
    name = "Debug executable",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

vim.keymap.set("n", "<leader>o", "<Nop>", { buffer = true, desc = "Operations" })
vim.keymap.set("n", "<leader>ob", function()
  run_cargo("cargo build")
end, { buffer = true, desc = "Build" })
vim.keymap.set("n", "<leader>ot", function()
  run_cargo("cargo test")
end, { buffer = true, desc = "Test" })
