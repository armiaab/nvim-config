local M = {}

local exe = vim.fn.fnamemodify(vim.v.progpath, ":h") .. "/win32yank.exe"
local last = nil
local last_text = nil
local checked_at = 0
local stale = true
local busy, pending = false, nil

local function flush()
  if busy or not pending then return end
  busy = true
  local text = pending
  pending = nil
  vim.system({ exe, "-i", "--crlf" }, { stdin = text }, function()
    busy = false
    vim.schedule(flush)
  end)
end

function M.copy(lines, regtype)
  local text = table.concat(lines, "\n")
  last, last_text = { lines, regtype }, text
  stale, checked_at = false, vim.uv.now()
  pending = text
  flush()
end

function M.paste()
  local fresh = not stale and vim.uv.now() - checked_at < 5000
  if last and (fresh or busy or pending) then return last end
  local r = vim.system({ exe, "-o", "--lf" }, { text = true }):wait()
  local text = r.stdout or ""
  stale, checked_at = false, vim.uv.now()
  if text ~= last_text then
    last, last_text = vim.split(text, "\n", { plain = true }), text
  end
  return last
end

function M.setup()
  if vim.fn.filereadable(exe) == 0 then return end
  local function copy(lines, regtype) M.copy(lines, regtype) end
  local function paste() return M.paste() end
  vim.g.clipboard = {
    name = "win32yank (async)",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = 0,
  }
  local group = vim.api.nvim_create_augroup("UserWinClip", { clear = true })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function() stale = true end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if (busy or pending) and last_text then
        vim.system({ exe, "-i", "--crlf" }, { stdin = last_text }):wait(2000)
      end
    end,
  })
end

return M