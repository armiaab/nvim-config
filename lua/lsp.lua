local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok then vim.lsp.config("*", { capabilities = cmp_lsp.default_capabilities() }) end

local clangd = vim.fn.glob(vim.env.LOCALAPPDATA .. "/Programs/clangd/clangd_*/bin/clangd.exe", true, true)
local clangd_cmd = { clangd[#clangd] or "clangd", "--background-index", "--header-insertion=never" }
local gpp = vim.fn.exepath("g++")
if gpp ~= "" then
  table.insert(clangd_cmd, "--query-driver=" .. vim.fn.fnamemodify(gpp, ":h"):gsub("\\", "/") .. "/*g++*")
end

vim.lsp.config("clangd", {
  cmd = clangd_cmd,
  filetypes = { "c", "cpp" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("basedpyright", {
  cmd = { "node", vim.env.APPDATA .. "/npm/node_modules/basedpyright/langserver.index.js", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  settings = { basedpyright = { analysis = { typeCheckingMode = "basic" } } },
})

vim.lsp.config("texlab", {
  cmd = { "texlab" },
  filetypes = { "tex", "plaintex", "bib" },
  root_markers = { ".latexmkrc", "latexmkrc", ".texlabroot", "texlabroot", ".git" },
  settings = {
    texlab = {
      chktex = { onOpenAndSave = true, onEdit = true },
      diagnosticsDelay = 300,
      latexFormatter = "latexindent",
      latexindent = { modifyLineBreaks = false },
      bibtexFormatter = "texlab",
    },
  },
})

vim.lsp.config("emmet_language_server", {
  cmd = { "emmet-language-server", "--stdio" },
  filetypes = {
    "astro", "css", "eruby", "html", "htmlangular", "htmldjango", "javascriptreact",
    "less", "sass", "scss", "svelte", "typescriptreact", "vue",
  },
  root_markers = { ".git" },
})

local sev = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { current_line = true },
  float = { border = "rounded" },
  signs = {
    text = { [sev.ERROR] = "", [sev.WARN] = "", [sev.INFO] = "", [sev.HINT] = "" },
    numhl = {
      [sev.ERROR] = "DiagnosticError",
      [sev.WARN] = "DiagnosticWarn",
      [sev.INFO] = "DiagnosticInfo",
      [sev.HINT] = "DiagnosticHint",
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLsp", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "texlab" then
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_loaded(ev.buf) then
          client:notify("textDocument/didSave", { textDocument = { uri = vim.uri_from_bufnr(ev.buf) } })
        end
      end, 500)
    end

    local function m(modes, lhs, rhs) vim.keymap.set(modes, lhs, rhs, { buffer = ev.buf }) end
    local function format() vim.lsp.buf.format({ async = true }) end
    m("n", "gd", vim.lsp.buf.definition)
    m("n", "gD", vim.lsp.buf.declaration)
    m("n", "gi", vim.lsp.buf.implementation)
    m("n", "gr", vim.lsp.buf.references)
    m("n", "K", vim.lsp.buf.hover)
    m("n", "gR", vim.lsp.buf.rename)
    m("n", "gA", vim.lsp.buf.code_action)
    m("n", "<leader>rn", vim.lsp.buf.rename)
    m("n", "<leader>ca", vim.lsp.buf.code_action)
    m("n", "<leader>fm", format)
    m({ "n", "x" }, "<leader>=", format)
    m("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end)
    m("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end)
  end,
})

vim.defer_fn(function()
  vim.lsp.enable({ "clangd", "lua_ls", "basedpyright", "texlab", "emmet_language_server" })
end, 0)
