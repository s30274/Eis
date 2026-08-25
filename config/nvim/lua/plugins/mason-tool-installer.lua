return {
	'WhoIsSethDaniel/mason-tool-installer.nvim',
	dependencies = { 'mason-org/mason.nvim' },
	opts = {
		ensure_installed = {
			'lua_ls',
			'gopls',
			'jsonls',
			'stylua',
			'prettier',
			'clangd',
			'bashls',
			'beautysh',
			'pyright',
		},
	},
}
