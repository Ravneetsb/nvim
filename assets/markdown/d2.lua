local function has_d2_class(classes)
  for _, class in ipairs(classes) do
    if class == "d2" then
      return true
    end
  end

  return false
end

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function mkdir_p(path)
  local ok = os.execute("mkdir -p " .. shell_quote(path))
  if ok ~= true and ok ~= 0 then
    error("failed to create D2 assets directory: " .. path)
  end
end

local function fnv1a(value)
  local hash = 2166136261

  for index = 1, #value do
    hash = hash ~ value:byte(index)
    hash = (hash * 16777619) & 0xffffffff
  end

  return string.format("%08x", hash)
end

local function sanitize_filename(value)
  local sanitized = value:gsub("%.[^%.]+$", ""):gsub("[^%w._-]+", "-")
  sanitized = sanitized:gsub("^-+", ""):gsub("-+$", "")

  if sanitized == "" then
    return "diagram"
  end

  return sanitized
end

local function input_file()
  local input_files = PANDOC_STATE and PANDOC_STATE.input_files or {}

  if #input_files == 0 then
    error("cannot render D2 diagrams without an input file")
  end

  return input_files[1]
end

local function output_directory()
  local export_dir = os.getenv("MARKDOWN_EXPORT_DIR")
  if export_dir and export_dir ~= "" then
    return export_dir
  end

  local output_file = PANDOC_STATE and PANDOC_STATE.output_file
  if output_file and output_file ~= "" then
    return pandoc.path.directory(output_file)
  end

  return pandoc.path.directory(input_file())
end

local function render_d2(source, output)
  pandoc.pipe("d2", { "-", output }, source)
end

function CodeBlock(block)
  if not has_d2_class(block.classes) then
    return nil
  end

  local source = input_file()
  local directory = output_directory()
  local assets_directory = pandoc.path.join({ directory, "assets" })
  local filename = sanitize_filename(pandoc.path.filename(source)) .. "-d2-" .. fnv1a(block.text) .. ".svg"
  local output = pandoc.path.join({ assets_directory, filename })
  local target = pandoc.path.join({ "assets", filename })

  mkdir_p(assets_directory)
  render_d2(block.text, output)

  return pandoc.Para({
    pandoc.Image({ pandoc.Str("D2 diagram") }, target, "", pandoc.Attr("", { "d2-diagram" })),
  })
end
