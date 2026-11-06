vim.loader.enable()

for _, provider in ipairs({ "python3", "node", "ruby", "perl" }) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.g.python_constant_highlight = 1

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.numberwidth = 2
opt.signcolumn = "no"
opt.cursorline = true
opt.cursorlineopt = "number"
opt.laststatus = 3
opt.showmode = false
opt.ruler = false
opt.fillchars = { eob = " " }
opt.shortmess:append("I")
opt.pumheight = 10
opt.list = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.scrolloff = 7
opt.sidescrolloff = 8
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.linebreak = true
opt.breakindent = true
opt.wildmode = "longest:full,full"
opt.wildignore = "*.o,*~,*.pyc,*/.git/*,*/node_modules/*,*/__pycache__/*"
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 500
opt.splitright = true
opt.splitbelow = true
opt.completeopt = "menu,menuone,noselect"
opt.fileformats = "unix,dos,mac"
opt.guicursor = "n-v-c-sm:block-Cursor,i-ci-ve:ver25,r-cr-o:hor20-Cursor,t:block-blinkon500-blinkoff500-TermCursor"

local ui2_ok, ui2 = pcall(require, "vim._core.ui2")
if ui2_ok then
  ui2.enable({ msg = { targets = "msg", msg = { timeout = 2500 } } })
  opt.cmdheight = 0
end

if vim.fn.has("win32") == 1 then
  require("winclip").setup()
  vim.env.PATHEXT = ".COM;.EXE;.BAT;.CMD"
  local bash = "C:/Program Files/Git/bin/bash.exe"
  if vim.fn.executable(bash) == 1 then
    vim.o.shell = '"' .. bash .. '"'
    vim.o.shellcmdflag = "-c"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
    vim.o.shellredir = ">'%s' 2>&1"
    vim.o.shellpipe = "2>&1| tee '%s'"
    vim.o.shelltemp = false
  end
end

local sep = vim.fn.has("win32") == 1 and ";" or ":"
vim.env.MASON = vim.fn.stdpath("data") .. "/mason"
vim.env.PATH = vim.env.MASON .. "/bin" .. sep .. vim.fn.expand("~/bin") .. sep .. vim.env.PATH

if vim.g.neovide then
  vim.o.guifont = "Victor Mono,InputMono,Consolas:h16"
  vim.o.linespace = 0
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_short_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_position_animation_length = 0
end

local places = require("places")
places.setup()
require("spelling").setup()

local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd

map("i", "jk", "<Esc>")
map("n", "0", "^")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "<leader>w", "<Cmd>write<CR>")
map("n", "<leader>c", "<Cmd>nohlsearch<CR>", { silent = true })
map("n", "<leader>l", "<Cmd>bnext<CR>")
map("n", "<leader>h", "<Cmd>bprevious<CR>")
map("n", "<leader>bd", "<Cmd>bdelete<CR>")
map("n", "<leader>tn", "<Cmd>tabnew<CR>")
map("n", "<leader>to", "<Cmd>tabonly<CR>")
map("n", "<leader>tc", "<Cmd>tabclose<CR>")
map("n", "<leader>cd", "<Cmd>cd %:p:h<CR><Cmd>pwd<CR>")
map("n", "<leader>e", "<Cmd>Neotree toggle<CR>")
map("n", "<leader>ss", function() require("spelling").toggle() end)
map("n", "<leader>q", function() vim.diagnostic.setloclist() end)
map("n", "<leader>m", "<Cmd>Make<CR>")
map("n", "<leader>ff", "<Cmd>Telescope find_files<CR>")
map("n", "<leader>fg", "<Cmd>Telescope live_grep<CR>")
map("n", "<leader>fb", "<Cmd>Telescope buffers<CR>")
map("n", "<leader>fr", "<Cmd>Telescope oldfiles<CR>")

map({ "n", "i", "x" }, "<C-s>", "<Cmd>silent update<CR>")
map("n", "<C-p>", "<Cmd>Telescope find_files<CR>")
map("n", "<C-S-p>", "<Cmd>Telescope commands<CR>")
map("n", "<C-S-f>", "<Cmd>Telescope live_grep<CR>")
map("n", "<C-/>", "gcc", { remap = true })
map("x", "<C-/>", "gc", { remap = true })
map("n", "<C-Tab>", "gt")
map("n", "<C-S-Tab>", "gT")
map("n", "<M-j>", "<Cmd>m .+1<CR>==")
map("n", "<M-k>", "<Cmd>m .-2<CR>==")
map("v", "<M-j>", ":m '>+1<CR>gv=gv")
map("v", "<M-k>", ":m '<-2<CR>gv=gv")
for i = 1, 9 do
  map("n", "<M-" .. i .. ">", i .. "gt")
  map("n", "<leader>" .. i, i .. "gt")
end
for _, key in ipairs({ "<C-`>", "<C-\\>" }) do
  map({ "n", "t" }, key, function() require("build").toggle_term() end)
end

vim.api.nvim_create_user_command("Make", function(o) require("build").make(o.args) end,
  { nargs = "*", bang = true, complete = "file" })
vim.cmd([[cnoreabbrev <expr> make (getcmdtype() ==# ':' && getcmdline() ==# 'make') ? 'Make' : 'make']])

local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

autocmd("FileType", {
  group = group,
  pattern = { "cpp", "python", "tex" },
  callback = function(ev) require("build").keys(ev.buf) end,
})

autocmd({ "FocusGained", "BufEnter" }, { group = group, command = "silent! checktime" })

autocmd("BufWritePre", {
  group = group,
  pattern = { "*.txt", "*.js", "*.ts", "*.py", "*.sh", "*.lua", "*.md", "*.c", "*.rs" },
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("TextYankPost", {
  group = group,
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

autocmd({ "BufWinEnter", "OptionSet" }, {
  group = group,
  callback = function(ev)
    if ev.event == "OptionSet" and ev.match ~= "shiftwidth" then return end
    vim.opt_local.listchars = {
      tab = "│ ",
      nbsp = "+",
      leadmultispace = "│" .. (" "):rep(math.max(vim.fn.shiftwidth() - 1, 0)),
    }
  end,
})

autocmd("TermOpen", {
  group = group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.list = false
  end,
})

autocmd("VimEnter", {
  group = group,
  once = true,
  callback = function()
    local argc = vim.fn.argc()
    if argc == 0 then
      local dir = vim.g.neovide and places.start_dir()
      if dir then vim.api.nvim_set_current_dir(dir) end
    elseif argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.api.nvim_set_current_dir(vim.fn.fnamemodify(vim.fn.argv(0), ":p"))
      local dirbuf = vim.api.nvim_get_current_buf()
      vim.cmd.enew()
      pcall(vim.api.nvim_buf_delete, dirbuf, { force = true })
      vim.schedule(function() vim.cmd("Neotree") end)
    end
  end,
})

autocmd("User", {
  group = group,
  pattern = "VeryLazy",
  once = true,
  callback = function() vim.defer_fn(function() require("lsp") end, 0) end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
opt.rtp:prepend(lazypath)

local function cmp_reset()
  local ok, cmp = pcall(require, "cmp")
  if ok and not cmp.close() then pcall(function() cmp.core:reset() end) end
end

local too_dull = vim.fn.expand("~/source/repos/too-dull.nvim")

require("lazy").setup({
  spec = {
    {
      dir = too_dull,
      name = "too-dull.nvim",
      cond = vim.uv.fs_stat(too_dull) ~= nil,
      lazy = false,
      priority = 1000,
      config = function() vim.cmd.colorscheme("too-dull") end,
    },

    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      cmd = "Neotree",
      dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
      opts = {
        close_if_last_window = true,
        enable_git_status = false,
        enable_diagnostics = false,
        window = { width = 28 },
        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 0,
            with_markers = false,
            with_expanders = true,
            expander_collapsed = "▸",
            expander_expanded = "▾",
          },
          icon = { folder_closed = "", folder_open = "", folder_empty = "", default = "" },
          modified = { symbol = "●" },
        },
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          filtered_items = {
            hide_gitignored = false,
            hide_dotfiles = true,
            show_hidden_count = false,
            never_show = {
              ".git", ".venv", "venv", "__pycache__", ".ipynb_checkpoints",
              ".virtual_documents", ".direnv", ".mypy_cache", ".pytest_cache",
              ".ruff_cache", "node_modules", ".DS_Store",
            },
          },
        },
      },
    },

    {
      "nvim-telescope/telescope.nvim",
      branch = "master",
      cmd = "Telescope",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
        defaults = {
          layout_strategy = "center",
          sorting_strategy = "ascending",
          layout_config = { anchor = "N", width = 0.6, height = 0.4, prompt_position = "top" },
          previewer = false,
          results_title = false,
          prompt_prefix = " ",
          selection_caret = " ",
          entry_prefix = " ",
        },
        pickers = { find_files = { follow = true } },
      },
    },

    {
      "lewis6991/gitsigns.nvim",
      event = "VeryLazy",
      opts = {
        signcolumn = false,
        numhl = true,
        on_attach = function(buf)
          local gs = require("gitsigns")
          local function m(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = buf }) end
          m("]g", function() gs.nav_hunk("next") end)
          m("[g", function() gs.nav_hunk("prev") end)
          m("<leader>gp", gs.preview_hunk)
          m("<leader>gb", gs.blame_line)
          m("<leader>gr", gs.reset_hunk)
          m("<leader>gs", gs.stage_hunk)
        end,
      },
    },

    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
    { "kylechui/nvim-surround", keys = { "ys", "yS", "ds", "cs", "cS", { "S", mode = "x" } }, opts = {} },

    {
      "mg979/vim-visual-multi",
      branch = "master",
      keys = {
        { "<C-n>", mode = { "n", "x" } },
        "<C-Down>",
        "<C-Up>",
      },
      init = function()
        vim.g.VM_silent_exit = 1
        vim.g.VM_show_warnings = 0
      end,
    },

    {
      "williamboman/mason.nvim",
      cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
      opts = {},
    },

    {
      "L3MON4D3/LuaSnip",
      lazy = true,
      dependencies = { "rafamadriz/friendly-snippets" },
      config = function()
        local ls = require("luasnip")
        ls.setup({
          enable_autosnippets = true,
          store_selection_keys = "<Tab>",
          update_events = "TextChanged,TextChangedI",
        })
        require("luasnip.loaders.from_vscode").lazy_load({ exclude = { "tex" } })
        require("luasnip.loaders.from_lua").lazy_load()
        map({ "i", "s" }, "<C-j>", function()
          if ls.expand_or_jumpable() then cmp_reset(); ls.expand_or_jump() end
        end)
        map({ "i", "s" }, "<C-k>", function()
          if ls.jumpable(-1) then cmp_reset(); ls.jump(-1) end
        end)
      end,
    },

    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        cmp.setup({
          snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<C-d>"] = cmp.mapping.scroll_docs(4),
            ["<C-u>"] = cmp.mapping.scroll_docs(-4),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_locally_jumpable() then
                cmp_reset()
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.locally_jumpable(-1) then
                cmp_reset()
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources(
            { { name = "luasnip" }, { name = "nvim_lsp" } },
            { { name = "buffer" }, { name = "path" } }
          ),
        })
        local ok, autopairs = pcall(require, "nvim-autopairs.completion.cmp")
        if ok then cmp.event:on("confirm_done", autopairs.on_confirm_done()) end
      end,
    },

    {
      "lervag/vimtex",
      ft = { "tex", "bib" },
      cmd = "VimtexInverseSearch",
      init = function()
        vim.g.tex_flavor = "latex"
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = vim.env.LOCALAPPDATA .. "/SumatraPDF/SumatraPDF.exe"
        vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
        vim.g.vimtex_compiler_latexmk_engines = { _ = "-xelatex" }
        vim.g.vimtex_quickfix_open_on_warning = 0
        vim.g.vimtex_quickfix_ignore_filters = { "Underfull", "Overfull" }
        vim.g.vimtex_syntax_custom_cmds = {
          { name = "ce", argspell = false },
          { name = "pu", argspell = false },
        }
      end,
    },
  },

  install = { colorscheme = { "too-dull", "habamax" } },
  rocks = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "zipPlugin", "netrwPlugin", "rplugin", "tutor" },
    },
  },
})

if not vim.g.colors_name then vim.cmd.colorscheme("habamax") end
require("statusline").setup()
