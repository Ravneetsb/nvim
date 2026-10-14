local cache = {}

local function render_math(math)
  local display = math.mathtype == "DisplayMath"
  local formula = (display and "\\displaystyle " or "") .. math.text
  if cache[formula] then
    return cache[formula]:clone()
  end

  local result = pandoc.system.with_temporary_directory("markdown-math", function(directory)
    return pandoc.system.with_working_directory(directory, function()
      local source = table.concat({
        "\\documentclass{article}",
        "\\usepackage{amsmath,amssymb}",
        "\\usepackage[active,tightpage]{preview}",
        "\\setlength\\PreviewBorder{0pt}",
        "\\newsavebox{\\equationbox}",
        "\\begin{document}",
        "\\sbox{\\equationbox}{$" .. formula .. "$}",
        "\\typeout{MATHDEPTH=\\the\\dp\\equationbox}",
        "\\begin{preview}\\usebox{\\equationbox}\\end{preview}",
        "\\end{document}",
      }, "\n")
      local file = assert(io.open("equation.tex", "w"))
      file:write(source)
      file:close()

      local ok, log = pcall(pandoc.pipe, "latex", {
        "-no-shell-escape", "-interaction=nonstopmode", "-halt-on-error", "equation.tex",
      }, "")
      if not ok then
        error("Could not render LaTeX math (requires latex, amsmath, amssymb and preview):\n" .. tostring(log))
      end

      pandoc.pipe("dvisvgm", {
        "--no-fonts", "--no-specials=ps", "--bbox=preview", "--verbosity=0", "--output=equation.svg", "equation.dvi",
      }, "")
      local image = assert(io.open("equation.svg", "r"))
      local svg = image:read("*a")
      image:close()
      local width = assert(tonumber(svg:match("width=['\"]([%d.]+)pt"))) / 9.96264
      local height = assert(tonumber(svg:match("height=['\"]([%d.]+)pt"))) / 9.96264
      local depth = assert(tonumber(log:match("MATHDEPTH=([%d.]+)pt"))) / 10
      local name = "math-" .. pandoc.utils.sha1(formula) .. ".svg"
      pandoc.mediabag.insert(name, "image/svg+xml", svg)

      local style = string.format("width:%.6fem;height:%.6fem;vertical-align:-%.6fem;", width, height, depth)
      if display then
        style = style .. "display:block;margin:1em auto;max-width:100%;"
      end
      return pandoc.Image({ pandoc.Str(math.text) }, name, "", pandoc.Attr("", { "math" }, { style = style }))
    end)
  end)
  cache[formula] = result
  return result:clone()
end

function Math(math)
  if FORMAT:match("html") then
    return render_math(math)
  end
end
