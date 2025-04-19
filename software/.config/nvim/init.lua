require("qiv1ne.core")
require("qiv1ne.lazy")
require("lazy").setup({
	-- ... your other config ...
	checker = {
		enabled = true, -- or false if you don't want periodic checks at all
		notify = false, -- disables notifications for config changes/updates
	},
	-- ... your other config ...
})
vim.cmd.colorscheme("zenbones")
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.opt.colorcolumn = "99"
