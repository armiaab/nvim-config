local ls = require("luasnip")
local s, t, i, f, d, sn = ls.snippet, ls.text_node, ls.insert_node,
  ls.function_node, ls.dynamic_node, ls.snippet_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin

local function math() return vim.fn["vimtex#syntax#in_mathzone"]() == 1 end
local function text() return not math() end

local function mcmd(line_to_cursor, trigger)
  return math() and line_to_cursor:sub(-#trigger - 1, -#trigger - 1) ~= "\\"
end

local function sel(_, parent)
  local raw = parent.snippet.env.LS_SELECT_RAW
  if type(raw) == "table" and #raw > 0 then return sn(nil, i(1, raw)) end
  return sn(nil, i(1))
end

local function auto(trig, nodes, condition, extra)
  local ctx = { trig = trig, snippetType = "autosnippet" }
  for k, v in pairs(extra or {}) do ctx[k] = v end
  return s(ctx, nodes, { condition = condition })
end

local function msym(trig, out, prio)
  return auto(trig, t(out), math, { wordTrig = false, priority = prio })
end

local function mword(trig, out)
  return auto(trig, t(out), mcmd)
end

local function postfix(suffix, cmd)
  return auto("%f[%a\\](%a)" .. suffix,
    f(function(_, snip) return "\\" .. cmd .. "{" .. snip.captures[1] .. "}" end),
    math, { trigEngine = "pattern", wordTrig = false })
end

local function env(trig, name, desc)
  return s({ trig = trig, desc = desc or name },
    fmta("\\begin{" .. name .. "}\n\t<>\n\\end{" .. name .. "}", { d(1, sel) }))
end

local function wrap(trig, cmd)
  return s({ trig = trig, desc = "\\" .. cmd .. "{selection}" },
    fmta("\\" .. cmd .. "{<>}<>", { d(1, sel), i(0) }))
end

local snippets = {
  s({ trig = "template", desc = "article skeleton" }, fmta([[
\documentclass[11pt]{article}
\usepackage{amsmath, amssymb, amsthm}
\usepackage{graphicx}
\usepackage{hyperref}

\title{<>}
\author{<>}
\date{\today}

\begin{document}
\maketitle

<>

\end{document}]], { i(1), i(2), i(0) })),

  s({ trig = "fig", desc = "figure" }, fmta([[
\begin{figure}[htbp]
	\centering
	\includegraphics[width=<>\linewidth]{<>}
	\caption{<>}
	\label{fig:<>}
\end{figure}]], { i(1, "0.8"), i(2), i(3), i(4) })),

  s({ trig = "tab", desc = "table" }, fmta([[
\begin{table}[htbp]
	\centering
	\caption{<>}
	\label{tab:<>}
	\begin{tabular}{<>}
		<>
	\end{tabular}
\end{table}]], { i(1), i(2), i(3, "lcr"), i(0) })),

  s({ trig = "item", desc = "itemize" },
    fmta("\\begin{itemize}\n\t\\item <>\n\\end{itemize}", { i(0) })),
  s({ trig = "enum", desc = "enumerate" },
    fmta("\\begin{enumerate}\n\t\\item <>\n\\end{enumerate}", { i(0) })),
  s({ trig = "eq", desc = "numbered equation" },
    fmta("\\begin{equation}\n\t<>\n\t\\label{eq:<>}\n\\end{equation}", { i(1), i(2) })),
  env("ali", "align*"),
  env("frame", "frame", "beamer frame"),
  env("thm", "theorem"),
  env("lem", "lemma"),
  env("defn", "definition"),
  env("pf", "proof"),

  s({ trig = "sec", desc = "\\section" }, fmta("\\section{<>}\n<>", { i(1), i(0) })),
  s({ trig = "ssec", desc = "\\subsection" }, fmta("\\subsection{<>}\n<>", { i(1), i(0) })),
  s({ trig = "sssec", desc = "\\subsubsection" }, fmta("\\subsubsection{<>}\n<>", { i(1), i(0) })),

  wrap("tbf", "textbf"),
  wrap("tit", "textit"),
  wrap("emph", "emph"),
  wrap("ttt", "texttt"),

  s({ trig = "chap", desc = "\\chapter" }, fmta("\\chapter{<>}\n\\label{chap:<>}\n<>", { i(1), i(2), i(0) })),
  s({ trig = "cite", desc = "\\cite" }, fmta("\\cite{<>}<>", { i(1), i(0) })),
  s({ trig = "ref", desc = "\\ref" }, fmta("\\ref{<>}<>", { i(1), i(0) })),
  s({ trig = "eqref", desc = "\\eqref" }, fmta("\\eqref{eq:<>}<>", { i(1), i(0) })),
  s({ trig = "lbl", desc = "\\label" }, fmta("\\label{<>}<>", { i(1), i(0) })),
  s({ trig = "fn", desc = "\\footnote" }, fmta("\\footnote{<>}<>", { d(1, sel), i(0) })),
  s({ trig = "pkg", desc = "\\usepackage" }, fmta("\\usepackage{<>}", { i(1) })),
  s({ trig = "img", desc = "\\includegraphics" },
    fmta("\\includegraphics[width=<>\\linewidth]{<>}", { i(1, "0.8"), i(2) })),
  s({ trig = "href", desc = "\\href" }, fmta("\\href{<>}{<>}<>", { i(1), d(2, sel), i(0) })),
  s({ trig = "subfig", desc = "two figures side by side (subcaption)" }, fmta([[
\begin{figure}[htbp]
	\centering
	\begin{subfigure}{0.48\linewidth}
		\includegraphics[width=\linewidth]{<>}
		\caption{<>}
	\end{subfigure}
	\hfill
	\begin{subfigure}{0.48\linewidth}
		\includegraphics[width=\linewidth]{<>}
		\caption{<>}
	\end{subfigure}
	\caption{<>}
	\label{fig:<>}
\end{figure}]], { i(1), i(2), i(3), i(4), i(5), i(6) })),
  s({ trig = "lst", desc = "code listing (listings)" },
    fmta("\\begin{lstlisting}[language=<>]\n<>\n\\end{lstlisting}", { i(1, "Python"), i(0) })),
  wrap("ce", "ce"),
}

local autosnippets = {
  auto("mk", fmta("$<>$<>", { d(1, sel), i(0) }), text),
  auto("dm", fmta("\\[\n\t<>\n\\]\n<>", { d(1, sel), i(0) }), text),
  auto("beg", fmta("\\begin{<>}\n\t<>\n\\end{<>}", { i(1), i(0), rep(1) }), line_begin),

  auto("//", fmta("\\frac{<>}{<>}<>", { i(1), i(2), i(0) }), math, { wordTrig = false }),
  auto("sq", fmta("\\sqrt{<>}<>", { d(1, sel), i(0) }), mcmd),
  auto("td", fmta("^{<>}<>", { i(1), i(0) }), math, { wordTrig = false }),
  auto("__", fmta("_{<>}<>", { i(1), i(0) }), math, { wordTrig = false }),
  msym("sr", "^2"),
  msym("cb", "^3"),

  auto("%f[%a\\](%a)(%d)",
    f(function(_, snip) return snip.captures[1] .. "_" .. snip.captures[2] end),
    math, { trigEngine = "pattern", wordTrig = false }),
  auto("%f[%a\\](%a)_(%d%d)",
    f(function(_, snip) return snip.captures[1] .. "_{" .. snip.captures[2] .. "}" end),
    math, { trigEngine = "pattern", wordTrig = false }),

  auto("sum", fmta("\\sum_{<>}^{<>} <>", { i(1, "n=1"), i(2, "\\infty"), i(0) }), mcmd),
  auto("prod", fmta("\\prod_{<>}^{<>} <>", { i(1, "n=1"), i(2, "N"), i(0) }), mcmd),
  auto("int", fmta("\\int_{<>}^{<>} <> \\,d<>", { i(1, "a"), i(2, "b"), i(3), i(4, "x") }), mcmd),
  auto("lim", fmta("\\lim_{<> \\to <>} <>", { i(1, "n"), i(2, "\\infty"), i(0) }), mcmd),

  auto("lrp", fmta("\\left( <> \\right)<>", { d(1, sel), i(0) }), mcmd),
  auto("lrb", fmta("\\left[ <> \\right]<>", { d(1, sel), i(0) }), mcmd),
  auto("lrc", fmta("\\left\\{ <> \\right\\}<>", { d(1, sel), i(0) }), mcmd),
  auto("lrv", fmta("\\left| <> \\right|<>", { d(1, sel), i(0) }), mcmd),
  auto("lra", fmta("\\left\\langle <> \\right\\rangle<>", { d(1, sel), i(0) }), mcmd),

  auto("tt", fmta("\\text{<>}<>", { i(1), i(0) }), mcmd),
  auto("mbb", fmta("\\mathbb{<>}<>", { i(1), i(0) }), mcmd),
  auto("mcal", fmta("\\mathcal{<>}<>", { i(1), i(0) }), mcmd),
  auto("mbf", fmta("\\mathbf{<>}<>", { i(1), i(0) }), mcmd),
  auto("mrm", fmta("\\mathrm{<>}<>", { i(1), i(0) }), mcmd),
  mword("RR", "\\mathbb{R}"),
  mword("NN", "\\mathbb{N}"),
  mword("ZZ", "\\mathbb{Z}"),
  mword("QQ", "\\mathbb{Q}"),
  mword("CC", "\\mathbb{C}"),

  msym("<=", "\\le "),
  msym(">=", "\\ge "),
  msym("!=", "\\neq "),
  msym("~~", "\\approx "),
  msym("->", "\\to "),
  msym("<->", "\\leftrightarrow ", 1001),
  msym("!>", "\\mapsto "),
  msym("=>", "\\implies "),
  msym("**", "\\cdot "),
  msym("...", "\\dots "),
  mword("iff", "\\iff "),
  mword("inn", "\\in "),
  mword("notin", "\\notin "),
  mword("AA", "\\forall "),
  mword("EE", "\\exists "),
  mword("xx", "\\times "),
  mword("ooo", "\\infty"),

  postfix("hat", "hat"),
  postfix("bar", "overline"),
  postfix("vec", "vec"),
  postfix("dot", "dot"),
  postfix("til", "tilde"),
}

return snippets, autosnippets