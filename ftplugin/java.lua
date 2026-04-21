local Terminal = require("toggleterm.terminal").Terminal

local function project_root()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil
  end

  return vim.fs.root(path, "pom.xml")
end

local function run_maven(cmd)
  local root = project_root()
  if not root then
    vim.notify("No pom.xml found for current Java buffer", vim.log.levels.WARN)
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

vim.keymap.set("n", "<leader>o", "<Nop>", { buffer = true, desc = "Operations" })
vim.keymap.set("n", "<leader>oc", function()
  run_maven("mvn compile")
end, { buffer = true, desc = "Compile" })
vim.keymap.set("n", "<leader>ob", function()
  run_maven("mvn clean package")
end, { buffer = true, desc = "Build" })
