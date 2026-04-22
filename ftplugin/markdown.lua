local Terminal = require("toggleterm.terminal").Terminal

local function current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Markdown buffer has no file path", vim.log.levels.WARN)
    return nil
  end

  return path
end

local function html_output_file(path)
  return vim.fn.fnamemodify(path, ":r") .. ".html"
end

local function pdf_output_file(path)
  return vim.fn.fnamemodify(path, ":r") .. ".pdf"
end

local function has_executable(name)
  if vim.fn.executable(name) == 1 then
    return true
  end

  vim.notify(name .. " is not installed or not on PATH", vim.log.levels.WARN)
  return false
end

local function pandoc_html_command(input, output)
  if vim.fn.executable("pandoc") ~= 1 then
    vim.notify("pandoc is not installed or not on PATH", vim.log.levels.WARN)
    return nil
  end

  local config = vim.fn.stdpath("config")
  local filter = config .. "/assets/markdown/callouts.lua"
  local css = config .. "/assets/markdown/callouts.css"

  return table.concat({
    "pandoc",
    vim.fn.shellescape(input),
    "--standalone",
    "--from markdown+mark",
    "--to html5",
    "--mathml",
    "--lua-filter " .. vim.fn.shellescape(filter),
    "--css " .. vim.fn.shellescape(css),
    "--output " .. vim.fn.shellescape(output),
  }, " ")
end

local function run_float(cmd, dir)
  Terminal:new({
    cmd = cmd,
    dir = dir,
    direction = "float",
    close_on_exit = false,
    hidden = true,
  }):toggle()
end

local function export_html()
  local input = current_file()
  if not input then
    return
  end

  local output = html_output_file(input)
  local cmd = pandoc_html_command(input, output)
  if not cmd then
    return
  end

  vim.b.markdown_pandoc_output = output
  run_float(cmd, vim.fn.fnamemodify(input, ":h"))
end

local function export_pdf()
  local input = current_file()
  if not input then
    return
  end

  if not has_executable("weasyprint") then
    return
  end

  local html_output = html_output_file(input)
  local pdf_output = pdf_output_file(input)
  local html_cmd = pandoc_html_command(input, html_output)
  if not html_cmd then
    return
  end

  local pdf_cmd = table.concat({
    "weasyprint",
    vim.fn.shellescape(html_output),
    vim.fn.shellescape(pdf_output),
  }, " ")

  vim.b.markdown_pandoc_output = html_output
  vim.b.markdown_pandoc_pdf_output = pdf_output
  run_float(html_cmd .. " && " .. pdf_cmd, vim.fn.fnamemodify(input, ":h"))
end

local function open_html()
  local input = current_file()
  if not input then
    return
  end

  local output = vim.b.markdown_pandoc_output or html_output_file(input)
  if vim.fn.filereadable(output) ~= 1 then
    vim.notify("HTML output does not exist: " .. output, vim.log.levels.WARN)
    return
  end

  if vim.ui.open then
    vim.ui.open(output)
  else
    vim.fn.jobstart({ "xdg-open", output }, { detach = true })
  end
end

local function open_pdf()
  local input = current_file()
  if not input then
    return
  end

  local output = vim.b.markdown_pandoc_pdf_output or pdf_output_file(input)
  if vim.fn.filereadable(output) ~= 1 then
    vim.notify("PDF output does not exist: " .. output, vim.log.levels.WARN)
    return
  end

  if vim.ui.open then
    vim.ui.open(output)
  else
    vim.fn.jobstart({ "xdg-open", output }, { detach = true })
  end
end

local function toggle_render_markdown()
  if vim.fn.exists(":RenderMarkdown") == 2 then
    vim.cmd("RenderMarkdown toggle")
  else
    vim.notify("RenderMarkdown command is not available", vim.log.levels.WARN)
  end
end

vim.keymap.set("n", "<leader>o", "<Nop>", { buffer = true, desc = "Operations" })
vim.keymap.set("n", "<leader>oh", export_html, { buffer = true, desc = "Export HTML" })
vim.keymap.set("n", "<leader>oo", open_html, { buffer = true, desc = "Open HTML" })
vim.keymap.set("n", "<leader>od", export_pdf, { buffer = true, desc = "Export PDF" })
vim.keymap.set("n", "<leader>oD", open_pdf, { buffer = true, desc = "Open PDF" })
vim.keymap.set("n", "<leader>op", toggle_render_markdown, { buffer = true, desc = "Toggle Render" })
