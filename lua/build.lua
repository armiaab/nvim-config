local M = {}

local bash = "C:/Program Files/Git/bin/bash.exe"
local gg = vim.fn.expand("~/bin/gg")
local has_gg = vim.fn.filereadable(gg) == 1
local run_buf, term_buf = -1, -1
local make_job

local function fwd(p) return (p:gsub("\\", "/")) end
local function echo(msg, hl) vim.api.nvim_echo({ { msg, hl } }, false, {}) end

function M.toggle_term()
  local win = vim.fn.bufwinid(term_buf)
  if win ~= -1 then return vim.api.nvim_win_close(win, true) end
  vim.cmd("botright 12new")
  if vim.api.nvim_buf_is_valid(term_buf) then
    local scratch = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_buf(0, term_buf)
    vim.api.nvim_buf_delete(scratch, { force = true })
  else
    vim.fn.jobstart(vim.o.shell, { term = true })
    term_buf = vim.api.nvim_get_current_buf()
    vim.bo[term_buf].buflisted = false
    local to_normal = [[<C-\><C-n>]]
    vim.keymap.set("t", "<Esc><Esc>", to_normal, { buffer = term_buf })
    vim.keymap.set("t", "jk", to_normal, { buffer = term_buf })
  end
  vim.cmd.startinsert()
end

function M.run(cmd, dir, use_input)
  if use_input then
    if vim.fn.filereadable(dir .. "/in") == 0 then
      return echo('No file named "in" next to the source', "WarningMsg")
    end
    local args = { bash, "-c", '"$@" < in', "run" }
    for _, a in ipairs(cmd) do table.insert(args, fwd(a)) end
    cmd = args
  end
  if vim.api.nvim_buf_is_valid(run_buf) then
    vim.api.nvim_buf_delete(run_buf, { force = true })
  end

  local src_win = vim.api.nvim_get_current_win()
  vim.cmd("belowright 12new")
  local buf = vim.api.nvim_get_current_buf()
  run_buf = buf
  vim.bo[buf].bufhidden = "wipe"
  local start = vim.uv.hrtime()
  vim.fn.jobstart(cmd, {
    term = true,
    cwd = dir,
    on_exit = function(_, code)
      vim.schedule(function()
        if vim.api.nvim_get_current_buf() == buf and vim.fn.mode() == "t" then
          vim.cmd.stopinsert()
        end
        echo(("exit %d   %.0f ms"):format(code, (vim.uv.hrtime() - start) / 1e6))
      end)
    end,
  })
  if use_input then
    vim.api.nvim_set_current_win(src_win)
  else
    vim.cmd.startinsert()
  end
end

function M.cpp(use_input)
  vim.cmd("silent update")
  local src, dir = vim.fn.expand("%:p"), vim.fn.expand("%:p:h")
  local exe = vim.fn.expand("%:p:r") .. ".exe"
  local efm = vim.bo.errorformat
  local cmd = has_gg and { bash, fwd(gg), fwd(src) }
    or { "g++", src, "-o", exe, "-std=c++23", "-O2", "-Wall", "-Wextra", "-Wshadow" }

  echo("Compiling " .. vim.fn.expand("%:t") .. "...")
  vim.system(cmd, { cwd = dir, text = true, stdin = false }, function(r)
    vim.schedule(function()
      local out = ((r.stderr or "") .. (r.stdout or "")):gsub("\r", "")
      vim.fn.setqflist({}, " ", { title = "gg", lines = vim.split(out, "\n", { trimempty = true }), efm = efm })
      if r.code ~= 0 then
        vim.cmd("botright copen")
        return echo("Compilation failed", "ErrorMsg")
      end
      local warnings = vim.tbl_filter(function(e) return e.valid == 1 end, vim.fn.getqflist())
      if #warnings > 0 then
        local win = vim.api.nvim_get_current_win()
        vim.cmd("botright copen")
        vim.api.nvim_set_current_win(win)
      else
        vim.cmd("cclose")
      end
      M.run({ exe }, dir, use_input)
    end)
  end)
end

function M.python(use_input)
  vim.cmd("silent update")
  M.run({ "python", vim.fn.expand("%:p") }, vim.fn.expand("%:p:h"), use_input)
end

local function find_makefile(dir)
  if dir == "" then return nil end
  local f = vim.fs.find({ "Makefile", "makefile", "GNUmakefile" },
    { upward = true, path = dir, stop = vim.uv.os_homedir(), limit = 1 })[1]
  return f and vim.fs.dirname(f)
end

local function has_tests(buf)
  for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 400, false)) do
    if l:match("^def test_") or l:match("^import pytest") then return true end
  end
  return false
end

function M.set_make(buf)
  local bo = vim.bo[buf]
  local function compiler(name) vim.api.nvim_buf_call(buf, function() vim.cmd.compiler(name) end) end
  if bo.filetype == "cpp" then
    compiler("gcc")
    bo.makeprg = has_gg and "gg %:S" or "g++ %:S -o %:r:S -std=c++23 -O2 -Wall -Wextra -Wshadow"
  elseif bo.filetype == "python" then
    if has_tests(buf) then
      compiler("pytest")
      bo.makeprg = "python -m pytest --tb=short --quiet %:S"
    else
      compiler("pyunit")
      bo.makeprg = "python -X utf8 %:S"
    end
  end
  local mk = find_makefile(vim.fs.dirname(vim.api.nvim_buf_get_name(buf)))
  if mk then bo.makeprg = "make -C " .. vim.fn.shellescape(fwd(mk)) end
end

function M.make(extra)
  extra = extra or ""
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if ft == "tex" and vim.fn.exists(":VimtexCompileSS") == 2 then
    return vim.cmd("VimtexCompileSS")
  end
  if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
    vim.cmd("silent! update")
    if ft == "cpp" or ft == "python" then M.set_make(buf) end
  end

  local prg = vim.bo[buf].makeprg
  if prg:find("$*", 1, true) then
    prg = prg:gsub("%$%*", (extra:gsub("%%", "%%%%")))
  elseif extra ~= "" then
    prg = prg .. " " .. extra
  end
  local cmd = vim.fn.expandcmd(prg)
  local efm = vim.bo[buf].errorformat ~= "" and vim.bo[buf].errorformat or vim.o.errorformat

  local argv = { (vim.o.shell:gsub('^"(.*)"$', "%1")) }
  vim.list_extend(argv, vim.split(vim.o.shellcmdflag, " ", { trimempty = true }))
  table.insert(argv, cmd)

  if make_job then make_job:kill(9) end
  local start = vim.uv.hrtime()
  echo("make: " .. cmd)
  local job
  job = vim.system(argv, { cwd = vim.fn.getcwd(), text = true, stdin = false }, function(r)
    vim.schedule(function()
      if make_job ~= job then return end
      make_job = nil
      local out = ((r.stdout or "") .. (r.stderr or "")):gsub("\r", "")
      vim.fn.setqflist({}, " ", { title = cmd, lines = vim.split(out, "\n", { trimempty = true }), efm = efm })
      local n = #vim.tbl_filter(function(e) return e.valid == 1 end, vim.fn.getqflist())
      local win = vim.api.nvim_get_current_win()
      if r.code ~= 0 or n > 0 then
        vim.cmd("botright copen")
        vim.api.nvim_set_current_win(win)
      else
        vim.cmd("cclose")
      end
      local secs = (vim.uv.hrtime() - start) / 1e9
      if r.code == 0 then
        echo(("make: done in %.1f s%s"):format(secs, n > 0 and (", " .. n .. " warnings") or ""))
      else
        echo(("make: failed (exit %d) in %.1f s, %d errors in the list"):format(r.code, secs, n), "ErrorMsg")
      end
    end)
  end)
  make_job = job
end

function M.keys(buf)
  local function m(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = buf }) end
  local function both(rhs) m("<F5>", rhs); m("<C-b>", rhs) end
  local ft = vim.bo[buf].filetype
  M.set_make(buf)
  if ft == "cpp" then
    both(function() M.cpp(false) end)
    m("<F6>", function() M.cpp(true) end)
  elseif ft == "python" then
    both(function() M.python(false) end)
    m("<F6>", function() M.python(true) end)
  elseif ft == "tex" then
    both("<Cmd>VimtexCompile<CR>")
    m("<F6>", "<Cmd>VimtexView<CR>")
  end
end

return M
