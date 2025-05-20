local M = {}

local Util = require("nvim-llm/utils")

local layout = require("nvim-llm.layout")

local function get_selected_text()
	local mode = vim.api.nvim_get_mode().mode
	local opts = {}
	-- \22 is an escaped version of <c-v>
	if mode == "v" or mode == "V" or mode == "\22" then
		opts.type = mode
	end
	return vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), opts)
end

function M.setup(opts)
	vim.keymap.set("n", "<Leader>hc", function()
		layout.toggle_chat_window()
	end)

	-- this only works in visual mode
	vim.keymap.set("v", "<Leader>he", function()
		local selection = get_selected_text()
		if #selection == 0 then
			print("Cannot explain emtpy selectoin")
			return
		end
		layout.toggle_chat_window()
		layout.full_ask_question(Util.format_explain_question(selection))
	end)
end

return M
