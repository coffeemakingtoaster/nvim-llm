local M = {}

local layout = require("nvim-llm.layout")

function M.setup(opts)
	vim.keymap.set("n", "<Leader>h", function()
		layout.toggle_chat_window()
	end)
end

return M
