return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = {
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		},
		formatters_by_ft = {
			-- go = { "gofumpt", "goimports" },
			javascript = { "biome" },
			css = { "prettier", "prettierd" },
			html = { "prettier", "prettierd" },
			json = { "prettier", "prettierd" },
			yaml = { "prettier", "prettierd" },
			markdown = { "prettier", "prettierd" },
			graphql = { "prettier", "prettierd" },
			liquid = { "prettier", "prettierd" },
			lua = { "stylua" },
			python = { "isort", "black" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	},
}
