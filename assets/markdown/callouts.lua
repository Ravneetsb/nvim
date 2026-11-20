local callout_titles = {
  note = "Note",
  tip = "Tip",
  important = "Important",
  warning = "Warning",
  caution = "Caution",
  error = "Error",
  danger = "Danger",
  failure = "Failure",
  fail = "Fail",
  missing = "Missing",
  bug = "Bug",
  info = "Info",
  question = "Question",
  quote = "Quote",
}

local callout_symbols = {
  note = "✎",
  tip = "◇",
  important = "!",
  warning = "⚠︎",
  caution = "⚠︎",
  error = "×",
  danger = "☠︎",
  failure = "×",
  fail = "×",
  missing = "⊖",
  bug = "※",
  info = "ℹ︎",
  question = "?",
  quote = "❝",
}

local function normalize_type(value)
  return value:lower():gsub("[^%w_-]", "")
end

local function trim_space(inlines)
  while #inlines > 0 and inlines[1].t == "Space" do
    table.remove(inlines, 1)
  end
  while #inlines > 0 and inlines[#inlines].t == "Space" do
    table.remove(inlines)
  end
  return inlines
end

local function split_at_break(inlines)
  local before = {}
  local after = {}
  local found_break = false

  for _, inline in ipairs(inlines) do
    if not found_break and (inline.t == "SoftBreak" or inline.t == "LineBreak") then
      found_break = true
    elseif found_break then
      after[#after + 1] = inline
    else
      before[#before + 1] = inline
    end
  end

  return trim_space(before), trim_space(after), found_break
end

local function parse_callout(inlines)
  local first = inlines[1]
  if not first or first.t ~= "Str" then
    return nil
  end

  local marker = first.text:match("^%[!([%w_-]+)%]$")
  if not marker then
    return nil
  end

  local callout_type = normalize_type(marker)
  local default_title = callout_titles[callout_type]
  if not default_title then
    return nil
  end

  local rest = {}
  for index = 2, #inlines do
    rest[#rest + 1] = inlines[index]
  end
  rest = trim_space(rest)

  local title_inlines, body_inlines, has_break = split_at_break(rest)
  local title = pandoc.utils.stringify(title_inlines)
  if title == "" or not has_break then
    title = title ~= "" and title or default_title
    body_inlines = has_break and body_inlines or {}
  end

  return callout_type, title, body_inlines
end

local function remove_first_block(blocks)
  local remaining = {}
  for index = 2, #blocks do
    remaining[#remaining + 1] = blocks[index]
  end
  return remaining
end

function BlockQuote(block)
  if #block.content == 0 then
    return nil
  end

  local first = block.content[1]
  if first.t ~= "Para" and first.t ~= "Plain" then
    return nil
  end

  local callout_type, title, body_inlines = parse_callout(first.content)
  if not callout_type then
    return nil
  end

  local content = remove_first_block(block.content)
  if #body_inlines > 0 then
    table.insert(content, 1, pandoc.Para(body_inlines))
  end
  table.insert(content, 1, pandoc.Para({
    pandoc.Span({ pandoc.Str(callout_symbols[callout_type]) },
      pandoc.Attr("", { "callout-symbol" }, { ["aria-hidden"] = "true" })),
    pandoc.Space(),
    pandoc.Str(title),
  }))

  return pandoc.Div(content, pandoc.Attr("", {
    "callout",
    "callout-" .. callout_type,
  }))
end
