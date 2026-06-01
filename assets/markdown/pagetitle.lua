local function has_meta_value(value)
  if value == nil then
    return false
  end

  return pandoc.utils.stringify(value) ~= ""
end

local function input_file()
  local input_files = PANDOC_STATE and PANDOC_STATE.input_files or {}
  return input_files[1]
end

local function filename_title()
  local path = input_file()
  if not path or path == "" then
    return nil
  end

  local name = pandoc.path.filename(path):gsub("%.[^%.]+$", "")
  name = name:gsub("[_-]+", " "):gsub("%s+", " ")
  name = name:gsub("^%s+", ""):gsub("%s+$", "")

  if name == "" then
    return nil
  end

  return name
end

local function first_h1_title(blocks)
  for _, block in ipairs(blocks) do
    if block.t == "Header" and block.level == 1 then
      local title = pandoc.utils.stringify(block.content)
      if title ~= "" then
        return title
      end
    end
  end

  return nil
end

function Pandoc(doc)
  if has_meta_value(doc.meta.pagetitle) or has_meta_value(doc.meta.title) then
    return nil
  end

  local title = first_h1_title(doc.blocks) or filename_title()
  if title then
    doc.meta.pagetitle = pandoc.MetaString(title)
    return doc
  end

  return nil
end
