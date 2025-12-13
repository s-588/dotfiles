local function map_split(buf_id, lhs, direction)
	local minifiles = require("mini.files")

	local function rhs()
		local window = minifiles.get_explorer_state().target_window

		-- Noop if the explorer isn't open or the cursor is on a directory.
		if window == nil or minifiles.get_fs_entry().fs_type == "directory" then
			return
		end

		-- Make a new window and set it as target.
		local new_target_window
		vim.api.nvim_win_call(window, function()
			vim.cmd(direction .. " split")
			new_target_window = vim.api.nvim_get_current_win()
		end)

		minifiles.set_target_window(new_target_window)

		-- Go in and close the explorer.
		minifiles.go_in({ close_on_file = true })
	end

	vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "Split " .. string.sub(direction, 12) })
end

return {
	-- Split/join blocks of code.
	{
		"nvim-mini/mini.splitjoin",
		keys = {
			{
				"<leader>cj",
				function()
					require("mini.splitjoin").toggle()
				end,
				desc = "Join/split code block",
			},
		},
		opts = {
			mappings = {
				toggle = "<leader>cj",
			},
		},
	},

	-- Moving selections.
	{
		"nvim-mini/mini.move",
		event = "BufReadPre",
		opts = {},
	},

	-- File explorer.
	{
		"nvim-mini/mini.files",
		keys = {
			{
				"<leader>e",
				function()
					local bufname = vim.api.nvim_buf_get_name(0)
					local path = vim.fn.fnamemodify(bufname, ":p")

					-- Noop if the buffer isn't valid.
					if path and vim.uv.fs_stat(path) then
						require("mini.files").open(bufname, false)
					end
				end,
				desc = "File explorer",
			},
		},
		opts = {
			mappings = {
				show_help = "?",
				go_in_plus = "<cr>",
				go_out_plus = "<tab>",
			},
			content = {
				filter = function(entry)
					return entry.fs_type ~= "file" or entry.name ~= ".DS_Store"
				end,
				sort = function(entries)
					local function compare_alphanumerically(e1, e2)
						-- Put directories first.
						if e1.is_dir and not e2.is_dir then
							return true
						end
						if not e1.is_dir and e2.is_dir then
							return false
						end
						-- Order numerically based on digits if the text before them is equal.
						if e1.pre_digits == e2.pre_digits and e1.digits ~= nil and e2.digits ~= nil then
							return e1.digits < e2.digits
						end
						-- Otherwise order alphabetically ignoring case.
						return e1.lower_name < e2.lower_name
					end

					local sorted = vim.tbl_map(function(entry)
						local pre_digits, digits = entry.name:match("^(%D*)(%d+)")
						if digits ~= nil then
							digits = tonumber(digits)
						end

						return {
							fs_type = entry.fs_type,
							name = entry.name,
							path = entry.path,
							lower_name = entry.name:lower(),
							is_dir = entry.fs_type == "directory",
							pre_digits = pre_digits,
							digits = digits,
						}
					end, entries)
					table.sort(sorted, compare_alphanumerically)
					-- Keep only the necessary fields.
					return vim.tbl_map(function(x)
						return { name = x.name, fs_type = x.fs_type, path = x.path }
					end, sorted)
				end,
			},
			windows = { width_nofocus = 25 },
			-- Move stuff to the minifiles trash instead of it being gone forever.
			options = { permanent_delete = false },
		},
		config = function(_, opts)
			local minifiles = require("mini.files")

			minifiles.setup(opts)

			-- Keep track of when the explorer is open to disable format on save.
			local minifiles_explorer_group = vim.api.nvim_create_augroup("s-588/minifiles_explorer", { clear = true })
			vim.api.nvim_create_autocmd("User", {
				group = minifiles_explorer_group,
				pattern = "MiniFilesExplorerOpen",
				callback = function()
					vim.g.minifiles_active = true
				end,
			})
			vim.api.nvim_create_autocmd("User", {
				group = minifiles_explorer_group,
				pattern = "MiniFilesExplorerClose",
				callback = function()
					vim.g.minifiles_active = false
				end,
			})

			-- Notify LSPs that a file got renamed or moved.
			vim.api.nvim_create_autocmd("User", {
				desc = "Notify LSPs that a file was renamed",
				pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
				callback = function(args)
					local changes = {
						files = {
							{
								oldUri = vim.uri_from_fname(args.data.from),
								newUri = vim.uri_from_fname(args.data.to),
							},
						},
					}
					local will_rename_method, did_rename_method =
						"workspace/willRenameFiles", "workspace/didRenameFiles"
					local clients = vim.lsp.get_clients()
					for _, client in ipairs(clients) do
						if client:supports_method(will_rename_method) then
							local res = client:request_sync(will_rename_method, changes, 1000, 0)
							if res and res.result then
								vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
							end
						end
					end

					for _, client in ipairs(clients) do
						if client:supports_method(did_rename_method) then
							client:notify(did_rename_method, changes)
						end
					end
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				desc = "Add minifiles split keymaps",
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local buf_id = args.data.buf_id
					map_split(buf_id, "<C-w>s", "belowright horizontal")
					map_split(buf_id, "<C-w>v", "belowright vertical")
				end,
			})
		end,
	},

	-- Remember the mappings.
	{
		"nvim-mini/mini.clue",
		event = "VeryLazy",
		opts = function()
			local miniclue = require("mini.clue")

			-- Some builtin keymaps that I don't use and that I don't want mini.clue to show.
			for _, lhs in ipairs({ "[%", "]%", "g%" }) do
				vim.keymap.del("n", lhs)
			end

			-- Add a-z/A-Z marks.
			local function mark_clues()
				local marks = {}
				vim.list_extend(marks, vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
				vim.list_extend(marks, vim.fn.getmarklist())

				return vim.iter(marks)
					:map(function(mark)
						local key = mark.mark:sub(2, 2)

						-- Just look at letter marks.
						if not string.match(key, "^%a") then
							return nil
						end

						-- For global marks, use the file as a description.
						-- For local marks, use the line number and content.
						local desc
						if mark.file then
							desc = vim.fn.fnamemodify(mark.file, ":p:~:.")
						elseif mark.pos[1] and mark.pos[1] ~= 0 then
							local line_num = mark.pos[2]
							local lines = vim.fn.getbufline(mark.pos[1], line_num)
							if lines and lines[1] then
								desc = string.format("%d: %s", line_num, lines[1]:gsub("^%s*", ""))
							end
						end

						if desc then
							return { mode = "n", keys = string.format("`%s", key), desc = desc }
						end
					end)
					:totable()
			end

			-- Clues for recorded macros.
			local function macro_clues()
				local res = {}
				for _, register in ipairs(vim.split("abcdefghijklmnopqrstuvwxyz", "")) do
					local keys = string.format('"%s', register)
					local ok, desc = pcall(vim.fn.getreg, register)
					if ok and desc ~= "" then
						---@cast desc string
						desc = string.format("register: %s", desc:gsub("%s+", " "))
						table.insert(res, { mode = "n", keys = keys, desc = desc })
						table.insert(res, { mode = "v", keys = keys, desc = desc })
					end
				end

				return res
			end

			return {
				triggers = {
					-- Builtins.
					{ mode = "n", keys = "g" },
					{ mode = "x", keys = "g" },
					{ mode = "n", keys = "`" },
					{ mode = "x", keys = "`" },
					{ mode = "n", keys = '"' },
					{ mode = "x", keys = '"' },
					{ mode = "i", keys = "<C-r>" },
					{ mode = "c", keys = "<C-r>" },
					{ mode = "n", keys = "<C-w>" },
					{ mode = "i", keys = "<C-x>" },
					{ mode = "n", keys = "z" },
					-- Leader triggers.
					{ mode = "n", keys = "<leader>" },
					{ mode = "x", keys = "<leader>" },
					-- Moving between stuff.
					{ mode = "n", keys = "[" },
					{ mode = "n", keys = "]" },
				},
				clues = {
					-- Leader/movement groups.
					{ mode = "n", keys = "<leader>a", desc = "+ai" },
					{ mode = "x", keys = "<leader>a", desc = "+ai" },
					{ mode = "n", keys = "<leader>b", desc = "+buffers" },
					{ mode = "n", keys = "<leader>c", desc = "+code" },
					{ mode = "x", keys = "<leader>c", desc = "+code" },
					{ mode = "n", keys = "<leader>d", desc = "+debug" },
					{ mode = "n", keys = "<leader>f", desc = "+find" },
					{ mode = "x", keys = "<leader>f", desc = "+find" },
					{ mode = "n", keys = "<leader>t", desc = "+tabs" },
					{ mode = "n", keys = "<leader>x", desc = "+loclist/quickfix" },
					{ mode = "n", keys = "[", desc = "+prev" },
					{ mode = "n", keys = "]", desc = "+next" },
					-- Builtins.
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
					-- Custom extras.
					mark_clues,
					macro_clues,
				},
				window = {
					delay = 500,
					scroll_down = "<C-f>",
					scroll_up = "<C-b>",
					config = function(bufnr)
						local max_width = 0
						for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
							max_width = math.max(max_width, vim.fn.strchars(line))
						end

						-- Keep some right padding.
						max_width = max_width + 2

						return {
							-- Dynamic width capped at 70.
							width = math.min(70, max_width),
						}
					end,
				},
			}
		end,
	},

	-- Better text objects.
	{
		"nvim-mini/mini.ai",
		event = "BufReadPre",
		dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
		opts = function()
			local miniai = require("mini.ai")
			return {
				n_lines = 300,
				custom_textobjects = {
					f = miniai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					-- Whole buffer.
					g = function()
						local from = { line = 1, col = 1 }
						local to = {
							line = vim.fn.line("$"),
							col = math.max(vim.fn.getline("$"):len(), 1),
						}
						return { from = from, to = to }
					end,
				},
				-- Disable error feedback.
				silent = true,
				-- Don't use the previous or next text object.
				search_method = "cover",
				mappings = {
					-- Disable next/last variants.
					around_next = "",
					inside_next = "",
					around_last = "",
					inside_last = "",
				},
			}
		end,
	},
}
