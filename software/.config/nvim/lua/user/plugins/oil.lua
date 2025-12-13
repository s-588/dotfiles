return {
	"stevearc/oil.nvim",
	dependencies = {
		"benomahony/oil-git.nvim",
		"JezerM/oil-lsp-diagnostics.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		delete_to_trash = true,
		view_options = {
			show_hidden = true,
		},
		preview_win = {
			preview_method = "load",
		},
	},
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
}
