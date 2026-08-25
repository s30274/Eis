return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    input = {
      -- your input configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
	picker = {
      enabled = true,
      -- Optional UI enhancements for vim.ui.select
      ui_select = true, 
    },
  }
}
