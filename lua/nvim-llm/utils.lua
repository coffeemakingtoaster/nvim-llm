local M = {}

vim.api.nvim_set_hl(0, string.format("answerpurple", "#b521ab"), { fg = "#b521ab" }) -- Gruvbox-style purple, change as needed
vim.api.nvim_set_hl(0, string.format("questionblue", "#3d85e3"), { fg = "#3d85e3" }) -- Gruvbox-style purple, change as needed

local function display_chat_message(bufferId, message, participant, color)
	-- Split message into lines
	local message_lines = vim.split(message, "\n", { plain = true })

	-- Prepare first line: "user: first line"
	local first_line = string.format("%s: %s", participant, message_lines[1])

	-- Lines to append: first formatted + rest (if any)
	local lines_to_append = { first_line }
	for i = 2, #message_lines do
		table.insert(lines_to_append, message_lines[i])
	end

	-- Get current end of buffer
	local line_count = vim.api.nvim_buf_line_count(bufferId)

	-- Append all lines
	vim.api.nvim_buf_set_lines(bufferId, line_count, line_count, false, lines_to_append)

	-- Apply highlight only to user part on the first appended line
	vim.api.nvim_buf_add_highlight(
		bufferId,
		-1,
		color,
		line_count, -- line number
		0, -- start at beginning
		#participant -- highlight only the user part (excluding ":")
	)
end

function M.display_answer(bufferId, text)
	display_chat_message(bufferId, text, "AI", "answerpurple")
end

function M.display_question(bufferId, text)
	display_chat_message(bufferId, text, "Me", "questionblue")
end

function M.format_explain_question(input)
	local codeBlock = table.concat(input, "\n")
	return string.format("Please explain this codesnippet to me:\n```\n%s\n```", codeBlock)
end

return M
