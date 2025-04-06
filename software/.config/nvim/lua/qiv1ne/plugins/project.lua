return {
	"ahmedkhalf/project.nvim",
	version = false,
	opts = {
		manual_mode = false, -- automactically add
	},
	event = "VeryLazy",
	config = function(_, opts)
		opts.detection_methods = { "lsp", "pattern" }
		opts.patterns = {
			".git",
			".hg",
			".svn",
		}
		require("project_nvim").setup(opts)
		require("telescope").load_extension("projects")
	end,
	keys = {
		{ "<leader>sp", "<Cmd>Telescope projects<CR>", desc = "[S]earch [P]rojects" },
	},
}
