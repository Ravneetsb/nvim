vim.schedule(function()
  local ok, registry = pcall(require, "mason-registry")
  if not ok then return end

  if not registry.has_package("codelldb") then
    vim.notify("codelldb is not installed", vim.log.levels.ERROR)
    return
  end

  local pkg = registry.get_package("codelldb")
local keys = {}
for k, _ in pairs(pkg) do table.insert(keys, k) end
print(vim.inspect(keys))

  -- auto-detect correct install path field
  local install_path = pkg.install_path
    or pkg._install_path
    or (pkg.get_install_path and pkg:get_install_path())
    or nil

  if not install_path then
    vim.notify("Could not determine codelldb install_path", vim.log.levels.ERROR)
    print("Package fields:", vim.inspect(pkg))
    return
  end

  local extension_path = install_path .. "/extension/"
  local codelldb_path = extension_path .. "adapter/codelldb"
  local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

  local dap = require("dap")

  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = codelldb_path,
      args = { "--port", "${port}", "--liblldb", liblldb_path },
    },
  }

  dap.configurations.rust = {
    {
      name = "Debug",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("exec: ", vim.fn.getcwd() .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
    },
  }
end)

