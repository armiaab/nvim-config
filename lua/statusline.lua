local M = {}
local api, fn = vim.api, vim.fn

local letters = {
  n = "N", no = "O", nov = "O", noV = "O", ["no\22"] = "O",
  niI = "N", niR = "N", niV = "N", nt = "N", ntT = "N",
  v = "V", vs = "V", V = "VL", Vs = "VL", ["\22"] = "VB", ["\22s"] = "VB",
  s = "S", S = "SL", ["\19"] = "SB",
  i = "I", ic = "I", ix = "I",
  R = "R", Rc = "R", Rx = "R", Rv = "VR", Rvc = "VR", Rvx = "VR",
  c = "C", cv = "EX", ce = "EX", r = "R", rm = "M", ["r?"] = "?", ["!"] = "!", t = "T",
}
local modes = {
  i = "insert", v = "visual", V = "visual", ["\22"] = "visual", s = "visual",
  S = "visual", ["\19"] = "visual", R = "replace", r = "replace", c = "command", t = "terminal",
}
local accents = {
  normal = "Function", insert = "DiagnosticOk", visual = "Constant",
  replace = "DiagnosticError", command = "Operator", terminal = "DiagnosticOk",
}
local severities = { { 1, "E", "Error" }, { 2, "W", "Warn" }, { 3, "I", "Info" }, { 4, "H", "Hint" } }

local function esc(s) return (s:gsub("%%", "%%%%")) end

function M.highlights()
  local function get(name) return api.nvim_get_hl(0, { name = name, link = false }) end
  local bg = get("StatusLine").bg
  for mode, group in pairs(accents) do
    api.nvim_set_hl(0, "StlMode_" .. mode, { fg = get("Normal").bg, bg = get(group).fg, bold = true })
  end
  for _, s in ipairs(severities) do
    api.nvim_set_hl(0, "StlDiag" .. s[3], { fg = get("Diagnostic" .. s[3]).fg, bg = bg })
  end
end

function M.statusline()
  local mode = api.nvim_get_mode().mode
  local buf = api.nvim_get_current_buf()
  local bo = vim.bo[buf]

  local name
  if bo.buftype ~= "" then
    name = bo.filetype ~= "" and bo.filetype or bo.buftype
  else
    name = fn.expand("%:~:.")
    name = name == "" and "untitled" or esc(name)
    if bo.modified then name = name .. " ●" end
    if bo.readonly or not bo.modifiable then name = name .. " ro" end
  end

  local right = {}
  if package.loaded["vim.diagnostic"] then
    local counts = vim.diagnostic.count(buf)
    for _, s in ipairs(severities) do
      if (counts[s[1]] or 0) > 0 then
        right[#right + 1] = ("%%#StlDiag%s#%s%d%%*"):format(s[3], s[2], counts[s[1]])
      end
    end
  end
  local head = vim.b[buf].gitsigns_head
  if head and head ~= "" then right[#right + 1] = esc(head) end
  if bo.fileencoding ~= "" and bo.fileencoding ~= "utf-8" then right[#right + 1] = bo.fileencoding end
  if bo.fileformat ~= "unix" then right[#right + 1] = bo.fileformat end
  right[#right + 1] = ("%d:%d"):format(fn.line("."), fn.charcol("."))

  return ("%%#StlMode_%s# %s %%* %s%%=%s "):format(
    modes[mode:sub(1, 1)] or "normal", letters[mode] or mode:sub(1, 2), name, table.concat(right, "  "))
end

function M.tabline()
  local cur, out = fn.tabpagenr(), {}
  for i, page in ipairs(api.nvim_list_tabpages()) do
    local buf = api.nvim_win_get_buf(api.nvim_tabpage_get_win(page))
    local name = fn.fnamemodify(api.nvim_buf_get_name(buf), ":t")
    out[#out + 1] = ("%%#%s#%%%dT %s%s "):format(
      i == cur and "TabLineSel" or "TabLine", i,
      name == "" and "untitled" or esc(name), vim.bo[buf].modified and " ●" or "")
  end
  return table.concat(out) .. "%#TabLineFill#%T"
end

function M.setup()
  M.highlights()
  vim.o.statusline = "%!v:lua.require'statusline'.statusline()"
  vim.o.tabline = "%!v:lua.require'statusline'.tabline()"
  local group = api.nvim_create_augroup("UserStatusline", { clear = true })
  api.nvim_create_autocmd("ColorScheme", { group = group, callback = M.highlights })
  api.nvim_create_autocmd({ "ModeChanged", "DiagnosticChanged" }, {
    group = group,
    callback = function() vim.cmd.redrawstatus() end,
  })
  api.nvim_create_autocmd("User", {
    group = group,
    pattern = "GitSignsUpdate",
    callback = function() vim.cmd.redrawstatus() end,
  })
end

return M
