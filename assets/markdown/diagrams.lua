local diagram_classes = {
  d2 = "d2",
  mermaid = "mermaid",
  dot = "graphviz",
  graphviz = "graphviz",
}

local graphviz_engines = {
  circo = true,
  dot = true,
  fdp = true,
  neato = true,
  osage = true,
  patchwork = true,
  sfdp = true,
  twopi = true,
}

local function diagram_kind(classes)
  for _, class in ipairs(classes) do
    if diagram_classes[class] then
      return diagram_classes[class]
    end
  end

  return nil
end

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function mkdir_p(path)
  local ok = os.execute("mkdir -p " .. shell_quote(path))
  if ok ~= true and ok ~= 0 then
    error("failed to create diagram assets directory: " .. path)
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
    error("cannot render diagrams without an input file")
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

local function output_format()
  if os.getenv("MARKDOWN_DIAGRAM_FORMAT") == "png" then
    return "png"
  end

  return "svg"
end

local function graphviz_engine(block)
  local engine = block.attributes.engine or "dot"
  if not graphviz_engines[engine] then
    local expected = "dot, neato, fdp, sfdp, circo, twopi, osage, or patchwork"
    error("unsupported Graphviz engine '" .. engine .. "' (expected " .. expected .. ")")
  end

  return engine
end

local function render(kind, source, output, format, engine)
  if kind == "d2" then
    pandoc.pipe(os.getenv("D2_BIN") or "d2", { "-", output }, source)
    return
  end

  if kind == "mermaid" then
    pandoc.pipe(os.getenv("MMDR_BIN") or "mmdr", { "-i", "-", "-o", output, "-e", format }, source)
    return
  end

  pandoc.pipe(os.getenv("GRAPHVIZ_BIN") or "dot", { "-K" .. engine, "-T" .. format, "-o", output }, source)
end

local function image_attributes(block, kind)
  local attributes = {}

  for _, name in ipairs({ "width", "height" }) do
    local value = block.attributes[name]
    if value and value ~= "" then
      attributes[name] = value
    end
  end

  return pandoc.Attr("", { "diagram", kind .. "-diagram" }, attributes)
end

function CodeBlock(block)
  local kind = diagram_kind(block.classes)
  if not kind then
    return nil
  end

  local engine = kind == "graphviz" and graphviz_engine(block) or ""
  local source = input_file()
  local directory = output_directory()
  local assets_directory = pandoc.path.join({ directory, "assets" })
  local format = output_format()
  local identity = table.concat({ kind, engine, format, block.text }, "\0")
  local basename = sanitize_filename(pandoc.path.filename(source))
  local filename = table.concat({ basename, kind, fnv1a(identity) }, "-") .. "." .. format
  local output = pandoc.path.join({ assets_directory, filename })
  local target = pandoc.path.join({ "assets", filename })

  mkdir_p(assets_directory)
  render(kind, block.text, output, format, engine)

  local labels = {
    d2 = "D2 diagram",
    graphviz = "Graphviz diagram",
    mermaid = "Mermaid diagram",
  }

  return pandoc.Para({
    pandoc.Image({ pandoc.Str(labels[kind]) }, target, "", image_attributes(block, kind)),
  })
end
