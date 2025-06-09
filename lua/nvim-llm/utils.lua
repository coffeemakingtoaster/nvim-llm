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
	-- local last_appended_line = line_count + #lines_to_append - 1
	-- vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(bufferId) - 1, 0 })
	--vim.cmd("normal! G")
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

function M.capture_visual_selection()
	local v_pos = vim.fn.getpos("v") -- start of visual
	local dot_pos = vim.fn.getpos(".") -- end of visual

	-- Convert to 0-based indices
	local start_row = math.min(v_pos[2], dot_pos[2]) - 1
	local end_row = math.max(v_pos[2], dot_pos[2]) - 1
	local start_col = (v_pos[2] < dot_pos[2] or (v_pos[2] == dot_pos[2] and v_pos[3] <= dot_pos[3])) and v_pos[3] - 1
		or dot_pos[3] - 1
	local end_col = (v_pos[2] > dot_pos[2] or (v_pos[2] == dot_pos[2] and v_pos[3] >= dot_pos[3])) and v_pos[3] - 1
		or dot_pos[3] - 1

	local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col + 1, end_col + 1)
	else
		lines[1] = string.sub(lines[1], start_col + 1)
		lines[#lines] = string.sub(lines[#lines], 1, end_col + 1)
	end

	local selection_text = table.concat(lines, "\n")
	return {
		start_row = start_row,
		start_col = start_col,
		end_row = end_row,
		end_col = end_col,
	},
		selection_text
end

-- Replace the previously selected range with new text
function M.replace_range(pos, new_text)
	local lines = vim.split(new_text, "\n", { plain = true })

	if pos.start_row == pos.end_row then
		local line = vim.api.nvim_buf_get_lines(0, pos.start_row, pos.start_row + 1, false)[1]
		local new_line = line:sub(1, pos.start_col) .. lines[1] .. line:sub(pos.end_col + 2)
		vim.api.nvim_buf_set_lines(0, pos.start_row, pos.start_row + 1, false, { new_line })
	else
		local old_lines = vim.api.nvim_buf_get_lines(0, pos.start_row, pos.end_row + 1, false)
		local first = old_lines[1]:sub(1, pos.start_col) .. lines[1]
		local last = lines[#lines] .. old_lines[#old_lines]:sub(pos.end_col + 2)
		lines[1] = first
		lines[#lines] = last
		vim.api.nvim_buf_set_lines(0, pos.start_row, pos.end_row + 1, false, lines)
	end
end

function M.clear_buffer(buffer_id)
	vim.api.nvim_buf_set_lines(buffer_id, 0, -1, false, {})
end

function M.write_full_conversation(buffer_id, conversation)
	assert(conversation ~= nil, "Cannot write a nil conversation")
	for _, v in ipairs(conversation) do
		if v.role == "assistant" then
			M.display_answer(buffer_id, v.content)
		else
			M.display_question(buffer_id, v.content)
		end
	end
end
return M
