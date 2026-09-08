local Terminal = require("toggleterm.terminal").Terminal

local function current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Markdown buffer has no file path", vim.log.levels.WARN)
    return nil
  end

  return path
end

local export_root = vim.fn.expand("~/Documents/exports")

local function export_dir(kind)
  return export_root .. "/" .. kind
end

local function template_suffix(template)
  if template == "academic" then
    return "-academic"
  end

  return ""
end

local function active_template(options)
  if options and options.template ~= nil then
    return options.template
  end

  return vim.b.markdown_pandoc_template
end

local function remember_template(template)
  vim.b.markdown_pandoc_template = template
end

local function ensure_export_dir(kind)
  local dir = export_dir(kind)
  if vim.fn.mkdir(dir, "p") == 1 then
    return dir
  end

  vim.notify("Could not create export directory: " .. dir, vim.log.levels.ERROR)
  return nil
end

local function html_output_file(path, template)
  local basename = vim.fn.fnamemodify(path, ":t:r") .. template_suffix(template)
  return export_dir("html") .. "/" .. basename .. ".html"
end

local function pdf_output_file(path, template)
  local basename = vim.fn.fnamemodify(path, ":t:r") .. template_suffix(template)
  return export_dir("pdf") .. "/" .. basename .. ".pdf"
end

local function has_executable(name)
  if vim.fn.executable(name) == 1 then
    return true
  end

  vim.notify(name .. " is not installed or not on PATH", vim.log.levels.WARN)
  return false
end

local function css_for_template(config, template)
  if template == "academic" then
    return config .. "/assets/markdown/academic.css"
  end

  return config .. "/assets/markdown/callouts.css"
end

local function pandoc_html_command(input, output, options)
  local renderers_available = true
  for _, executable in ipairs({ "pandoc", "d2", "mmdr", "dot" }) do
    if not has_executable(executable) then
      renderers_available = false
    end
  end

  if not renderers_available then
    return nil
  end

  options = options or {}

  local config = vim.fn.stdpath("config")
  local pagetitle_filter = config .. "/assets/markdown/pagetitle.lua"
  local callout_filter = config .. "/assets/markdown/callouts.lua"
  local diagrams_filter = config .. "/assets/markdown/diagrams.lua"
  local css = css_for_template(config, options.template)
  local input_dir = vim.fn.fnamemodify(input, ":h")
  local output_dir = vim.fn.fnamemodify(output, ":h")
  local resource_path = table.concat({ input_dir, output_dir }, ":")
  local d2_bin = vim.fn.exepath("d2")
  local mmdr_bin = vim.fn.exepath("mmdr")
  local graphviz_bin = vim.fn.exepath("dot")

  return table.concat({
    "MARKDOWN_EXPORT_DIR=" .. vim.fn.shellescape(output_dir),
    "D2_BIN=" .. vim.fn.shellescape(d2_bin),
    "MMDR_BIN=" .. vim.fn.shellescape(mmdr_bin),
    "GRAPHVIZ_BIN=" .. vim.fn.shellescape(graphviz_bin),
    "MARKDOWN_DIAGRAM_FORMAT=" .. vim.fn.shellescape(options.diagram_format or "svg"),
    "pandoc",
    vim.fn.shellescape(input),
    "--standalone",
    "--from markdown+mark",
    "--to html5",
    "--mathml",
    "--embed-resources",
    "--resource-path " .. vim.fn.shellescape(resource_path),
    "--lua-filter " .. vim.fn.shellescape(pagetitle_filter),
    "--lua-filter " .. vim.fn.shellescape(callout_filter),
    "--lua-filter " .. vim.fn.shellescape(diagrams_filter),
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

local function open_command(path)
  return table.concat({
    "xdg-open",
    vim.fn.shellescape(path),
  }, " ")
end

local function export_html(options)
  options = options or {}

  local input = current_file()
  if not input then
    return
  end

  if not ensure_export_dir("html") then
    return
  end

  local output = html_output_file(input, options.template)
  local cmd = pandoc_html_command(input, output, options)
  if not cmd then
    return
  end

  vim.b.markdown_pandoc_output = output
  remember_template(options.template)

  if options.open_after then
    cmd = cmd .. " && " .. open_command(output)
  end

  run_float(cmd, vim.fn.fnamemodify(input, ":h"))
end

local function export_pdf(options)
  options = options or {}

  local input = current_file()
  if not input then
    return
  end

  if not has_executable("weasyprint") then
    return
  end

  if not ensure_export_dir("html") or not ensure_export_dir("pdf") then
    return
  end

  local html_output = html_output_file(input, options.template)
  local pdf_output = pdf_output_file(input, options.template)
  local html_cmd = pandoc_html_command(input, html_output, options)
  if not html_cmd then
    return
  end

  local pdf_cmd = table.concat({
    "weasyprint",
    "--presentational-hints",
    vim.fn.shellescape(html_output),
    vim.fn.shellescape(pdf_output),
  }, " ")

  vim.b.markdown_pandoc_output = html_output
  vim.b.markdown_pandoc_pdf_output = pdf_output
  remember_template(options.template)

  local cmd = html_cmd .. " && " .. pdf_cmd
  if options.open_after then
    cmd = cmd .. " && " .. open_command(pdf_output)
  end

  run_float(cmd, vim.fn.fnamemodify(input, ":h"))
end

local function export_default_html()
  export_html()
end

local function export_default_pdf()
  export_pdf()
end

local function export_academic_html()
  export_html({ template = "academic" })
end

local function export_academic_pdf()
  export_pdf({ template = "academic" })
end

local function open_html(options)
  options = options or {}

  local input = current_file()
  if not input then
    return
  end

  local template = active_template(options)
  export_html({ template = template, open_after = true })
end

local function open_pdf(options)
  options = options or {}

  local input = current_file()
  if not input then
    return
  end

  local template = active_template(options)
  export_pdf({ template = template, open_after = true })
end

local function open_academic_html()
  open_html({ template = "academic" })
end

local function open_academic_pdf()
  open_pdf({ template = "academic" })
end

local function toggle_render_markdown()
  if vim.fn.exists(":RenderMarkdown") == 2 then
    vim.cmd("RenderMarkdown toggle")
  else
    vim.notify("RenderMarkdown command is not available", vim.log.levels.WARN)
  end
end

vim.keymap.set("n", "<leader>o", "<Nop>", { buffer = true, desc = "Operations" })
vim.keymap.set("n", "<leader>oh", export_default_html, { buffer = true, desc = "Export HTML" })
vim.keymap.set("n", "<leader>oH", export_academic_html, { buffer = true, desc = "Export Academic HTML" })
vim.keymap.set("n", "<leader>oo", open_html, { buffer = true, desc = "Open HTML" })
vim.keymap.set("n", "<leader>oO", open_academic_html, { buffer = true, desc = "Open Academic HTML" })
vim.keymap.set("n", "<leader>od", export_default_pdf, { buffer = true, desc = "Export PDF" })
vim.keymap.set("n", "<leader>oP", export_academic_pdf, { buffer = true, desc = "Export Academic PDF" })
vim.keymap.set("n", "<leader>oD", open_pdf, { buffer = true, desc = "Open PDF" })
vim.keymap.set("n", "<leader>oR", open_academic_pdf, { buffer = true, desc = "Open Academic PDF" })
vim.keymap.set("n", "<leader>op", toggle_render_markdown, { buffer = true, desc = "Toggle Render" })
vim.keymap.set("n", "<leader>ot", "<Cmd>AerialToggle right<CR>", { buffer = true, desc = "Toggle Heading Outline" })
