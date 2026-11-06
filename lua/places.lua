local M = {}

function M.active_dirs()
  local out = {}
  for _, root in ipairs({ vim.env.AP or false, vim.env.AU or false }) do
    if root and vim.fn.isdirectory(root) == 1 then
      for name, kind in vim.fs.dir(root) do
        if kind == "directory" then
          out[#out + 1] = { name = name, path = root .. "/" .. name, unj = root == vim.env.AU }
        end
      end
    end
  end
  table.sort(out, function(a, b) return a.name:lower() < b.name:lower() end)
  return out
end

local function go(dir)
  vim.api.nvim_set_current_dir(dir)
  vim.cmd("Neotree")
end

function M.active(arg)
  if arg == "" then return go(vim.env.ACTIVE) end
  local want = arg:lower()
  local hits = vim.tbl_filter(function(d)
    return d.name:lower():find(want, 1, true) ~= nil
  end, M.active_dirs())
  if #hits == 0 then
    vim.notify("No Active folder has '" .. arg .. "' in its name", vim.log.levels.WARN)
  elseif #hits == 1 then
    go(hits[1].path)
  else
    vim.ui.select(hits, {
      prompt = "Active folder",
      format_item = function(d) return d.name .. "   (" .. (d.unj and "UNJ" or "personal") .. ")" end,
    }, function(d) if d then go(d.path) end end)
  end
end

function M.start_dir()
  for _, dir in ipairs({ vim.env.ACTIVE or false, vim.env.CP or false }) do
    if dir and vim.fn.isdirectory(dir) == 1 then return dir end
  end
end

function M.setup()
  local home = vim.env.USERPROFILE or vim.env.HOME
  local od, odu = vim.env.OneDriveConsumer, vim.env.OneDriveCommercial
  if home then vim.env.ACTIVE = home .. "/Active" end
  if od and od ~= "" then
    vim.env.AP = od .. "/Active"
    vim.env.CP = od .. "/Active/Programming/Competitive Programming"
  end
  if odu and odu ~= "" then vim.env.AU = odu .. "/Active" end

  vim.api.nvim_create_user_command("Active", function(o) M.active(o.args) end, {
    nargs = "?",
    complete = function(lead)
      lead = lead:lower()
      local names = {}
      for _, d in ipairs(M.active_dirs()) do
        if d.name:lower():find(lead, 1, true) then names[#names + 1] = d.name end
      end
      return names
    end,
  })
end

return M
