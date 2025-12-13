-- Keeping the cursor centered.
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll downwards" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll upwards" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result" })

-- Indent while remaining in visual mode.
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Formatting.
vim.keymap.set("n", "gQ", "mzgggqG`z<cmd>delmarks z<cr>zz", { desc = "Format buffer" })

-- Open the package manager.
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Restart Neovim.
vim.keymap.set("n", "<leader>R", "<cmd>restart<cr>", { desc = "Restart Neovim" })

-- Poweful <esc>.
vim.keymap.set({ "i", "s", "n" }, "<esc>", function()
	if require("luasnip").expand_or_jumpable() then
		require("luasnip").unlink_current()
	end
	vim.cmd("noh")
	return "<esc>"
end, { desc = "Escape, clear hlsearch, and stop snippet session", expr = true })

-- Escape and save changes.
vim.keymap.set({ "s", "i", "n", "v" }, "<C-s>", "<esc>:w<cr>", { desc = "Exit insert mode and save changes" })
vim.keymap.set({ "s", "i", "n", "v" }, "<C-S-s>", function()
	vim.g.skip_formatting = true
	return "<esc>:w<cr>"
end, { desc = "Exit insert mode and save changes (without formatting)", expr = true })

-- Mark management.
vim.keymap.set("c", "dm", "delmarks", { desc = "Delete marks" })
