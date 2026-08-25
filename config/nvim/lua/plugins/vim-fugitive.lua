return {
	"tpope/vim-fugitive",
	keys = { -- load the plugin only when using it's keybinding:
		{ "<leader>gs", "<cmd>lua require('vim-fugitive').cmd.Git()<cr>" },
	},
}
