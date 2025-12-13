return {
	"ray-x/go.nvim",
	dependencies = { -- optional packages
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function(opts)
		require("go").setup(opts)
		local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.go",
			callback = function()
				require("go.format").goimports()
			end,
			group = format_sync_grp,
		})
		vim.keymap.set("n", "<leader>cgf", "<cmd>GoFillStruct<CR>", { desc = "[C]ode [G]olang auto [F]ill struct" })
		vim.keymap.set("n", "<leader>cge", "<cmd>GoFillStruct<CR>", { desc = "[C]ode [G]olang add if != [E]rr { }" })
	end,
	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
