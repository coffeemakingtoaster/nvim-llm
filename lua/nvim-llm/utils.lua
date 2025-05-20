local M = {}

vim.api.nvim_set_hl(0, string.format("answerpurple", "#b521ab"), { fg = "#b521ab" }) -- Gruvbox-style purple, change as needed
vim.api.nvim_set_hl(0, string.format("questionblue", "#3d85e3"), { fg = "#3d85e3" }) -- Gruvbox-style purple, change as needed

local function display_chat_message(bufferId, message, participant, color)
	-- Construct the full line
	local line = string.format("%s: %s", participant, message)

	-- Append the line at the end of the buffer
	local line_count = vim.api.nvim_buf_line_count(bufferId)
	vim.api.nvim_buf_set_lines(bufferId, line_count, line_count, false, { line })

	-- Apply highlight only to the `<user>` part
	local user_length = #participant
	vim.api.nvim_buf_add_highlight(bufferId, -1, color, line_count, 0, user_length)
end

function M.display_answer(bufferId, text)
	display_chat_message(bufferId, text, "AI", "answerpurple")
end

function M.display_question(bufferId, text)
	display_chat_message(bufferId, text, "Me", "questionblue")
end

return M
