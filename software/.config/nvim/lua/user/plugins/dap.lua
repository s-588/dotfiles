return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"jay-babu/mason-nvim-dap.nvim",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local mason_dap = require("mason-nvim-dap")
			local dap = require("dap")
			local ui = require("dapui")
			local dap_virtual_text = require("nvim-dap-virtual-text")
			dap_virtual_text.setup()

			mason_dap.setup({
				ensure_installed = { "cppdbg", "delve" },
				automatic_installation = true,
				handlers = {
					function(config)
						require("mason-nvim-dap").default_setup(config)
					end,
				},
			})

			-- Configurations
			dap.configurations = {
				go = {
					{
						type = "delve",
						name = "Debug",
						request = "launch",
						program = "${file}",
					},
					{
						type = "delve",
						name = "Debug test", -- configuration for debugging test files
						request = "launch",
						mode = "test",
						program = "${file}",
					},
					-- works with go.mod packages and sub packages
					{
						type = "delve",
						name = "Debug test (go.mod)",
						request = "launch",
						mode = "test",
						program = "./${relativeFileDirname}",
					},
				},
				c = {
					{
						name = "Launch file",
						type = "cppdbg",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopAtEntry = false,
						MIMode = "lldb",
					},
					{
						name = "Attach to lldbserver :1234",
						type = "cppdbg",
						request = "launch",
						MIMode = "lldb",
						miDebuggerServerAddress = "localhost:1234",
						miDebuggerPath = "/usr/bin/lldb",
						cwd = "${workspaceFolder}",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
					},
				},
			}

			-- Dap UI

			ui.setup()

			vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
		end,
	},
}
