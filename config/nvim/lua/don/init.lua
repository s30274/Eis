require("config.lazy")
require("don.remap")
require("don.colors")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.cmd"packadd nvim.undotree"

vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			runtime = { version = 'LuaJIT' },
			diagnostics = { globals = { 'vim' } },
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
	  			},
			},
			telemetry = { enable = false },
		},
	},
})

local signs = {
  Error = "✘ ",
  Warn  = " ",
  Info  = " ",
  Hint  = "",
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = function(diagnostic)
      local icons = {
        [vim.diagnostic.severity.ERROR] = "✘", -- Nerd Font Error Icon
        [vim.diagnostic.severity.WARN]  = "", -- Nerd Font Warning Icon
        [vim.diagnostic.severity.INFO]  = "", -- Nerd Font Info Icon
        [vim.diagnostic.severity.HINT]  = "", -- Nerd Font Hint Icon
      }
      return icons[diagnostic.severity] or "●"
    end,
  },
})

--vim.lsp.config('gopls', {
--  settings = {
--    gopls = {
--      staticcheck = true,
--      gofumpt = true,
--      usePlaceholders = true,
--    },
--  },
