return {
	{
		"sainnhe/sonokai",
		lazy = false,
		priority = 1000,
		config = function()
			-- Optionally configure and load the colorscheme
			-- directly inside the plugin declaration.
			vim.g.sonokai_style = "shusia"
			vim.g.sonokai_enable_italic = true
			-- vim.cmd.colorscheme("sonokai")
		end,
	},
	{
		"vague2k/vague.nvim",
		config = function()
			-- NOTE: you do not need to call setup if you don't want to.
			require("vague").setup({
				-- optional configuration here
			})
		end,
	},
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}
