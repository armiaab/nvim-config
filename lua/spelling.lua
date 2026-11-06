local M = {}

local prose = {
  "text", "markdown", "tex", "plaintex", "gitcommit", "mail",
  "rst", "typst", "asciidoc", "org", "norg",
}
local ready = false

function M.init()
  if ready then return end
  ready = true
  if #vim.api.nvim_get_runtime_file("spell/id.utf-8.spl", false) > 0 then
    vim.opt.spelllang = { "en", "id" }
  end
  local add = vim.o.spellfile
  if vim.fn.filereadable(add) == 1 and vim.fn.getftime(add) > vim.fn.getftime(add .. ".spl") then
    vim.cmd("silent mkspell! " .. vim.fn.fnameescape(add))
  end
end

local function enable(buf)
  M.init()
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_set_option_value("spell", true, { scope = "local", win = win })
  end
  vim.keymap.set("i", "<C-l>", "<C-g>u<Esc>[s1z=`]a<C-g>u", { buffer = buf })
end

function M.toggle()
  M.init()
  vim.wo.spell = not vim.wo.spell
end

function M.setup()
  vim.opt.spelllang = { "en" }
  vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/mixed.utf-8.add"
  vim.opt.spellsuggest = "best,10"
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserSpelling", { clear = true }),
    pattern = prose,
    callback = function(ev)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then enable(ev.buf) end
      end)
    end,
  })
end

return M
