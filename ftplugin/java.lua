local home = vim.env.HOME
local mason_path = home .. "/.local/share/nvim/mason/packages"
local bundles = {}

vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n"))
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "/java-test/extension/server/*.jar"), "\n"))

require("jdtls").start_or_attach({
  cmd = { "jdtls", "-data", home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t") },
  root_dir = require("jdtls.setup").find_root({ "gradlew", "mvnw", ".git" }),
  init_options = { bundles = bundles },
})

