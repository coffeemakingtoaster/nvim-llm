local M = {}
local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local LLM = require("nvim-llm.llm")
local Tool = require("nvim-llm.tools")
local Util = require("nvim-llm.utils")
local sessions = require("nvim-llm.llm.sessions")
local utils = require("nvim-llm.llm.utils")
local prompt = "> "

M.is_displaying_w = false
M.active_index = 0

-- Answer popup
M.answer_popup = Popup({
	border = {
		style = "single",
		text = { top = "nvim-llm" },
	},
})

-- Question input
M.question_input = Input({
	border = {
		style = "single",
		text = {
			top = "Ask away!",
			top_align = "center",
		},
	},
	win_options = {
		winhighlight = "Normal:Normal,FloatBorder:Normal",
	},
}, {
	prompt = "> ",
	default_value = "",
	on_submit = function(value)
		print("Input Submitted: " .. value)
	end,
})

-- Chat selection popup
M.chat_selection = Popup({
	border = {
		style = "single",
		text = { top = "Chats" },
	},
	buf_options = {
		modifiable = false,
		readonly = true,
	},
})

-- Layout with chat selection on the right
M.layout = Layout(
	{
		position = "50%",
		size = {
			width = 150,
			height = 40,
		},
	},
	Layout.Box({
		-- Left column: chat + input
		Layout.Box({
			Layout.Box(M.answer_popup, { size = "90%" }),
			Layout.Box(M.question_input, { size = { height = "10%" } }),
		}, { dir = "col", size = "80%" }),

		-- Right column: chat selection
		Layout.Box(M.chat_selection, { size = "20%" }),
	}, { dir = "row" })
)

-- Function to update chat selection list
function M.update_chat_selection(chat_list)
	local lines = {}
	local active_index = nil

	for i, chat in ipairs(chat_list) do
		table.insert(lines, chat.name)
		if chat.is_active then
			print(chat.name)
			active_index = i - 1 -- 0-based index for nvim_buf_add_highlight
		end
	end

	local bufnr = M.chat_selection.bufnr
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)

	if active_index then
		vim.api.nvim_buf_add_highlight(bufnr, -1, "answerpurple", active_index, 0, -1)
		M.active_index = active_index
	end

	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

-- Run once to ensure populated side panel
M.update_chat_selection(sessions.get_session_list())

vim.keymap.set({ "n", "i" }, "<Enter>", function()
	local value = string.sub(vim.api.nvim_get_current_line(), vim.fn.strwidth(prompt) + 1)
	local response, summary = LLM.ask(value, sessions.get_active())
	Util.display_question(M.answer_popup.bufnr, value)
	Util.display_answer(M.answer_popup.bufnr, response)

	M.answer_popup.border:set_text("top", summary, "center")

	vim.api.nvim_win_call(M.answer_popup.winid, function()
		vim.cmd("normal! G")
	end)

	-- clear input field
	vim.api.nvim_set_current_line("")

	M.update_chat_selection(sessions.get_session_list())
end, { buffer = M.question_input.bufnr })

vim.keymap.set({ "n" }, "<Leader>hn", function()
	LLM.start_new_ask_session()
	Util.clear_buffer(M.answer_popup.bufnr)
	M.update_chat_selection(sessions.get_session_list())
	print(sessions.get_session_list())
	M.answer_popup.border:set_text("top", "New chat", "center")
end, { desc = "[H]elp from llama in [N]ew chat" })

function M.new_auto_chat()
	M.toggle_chat_window()
	LLM.start_new_ask_session()
	Util.clear_buffer(M.answer_popup.bufnr)
	M.update_chat_selection(sessions.get_session_list())
	print(sessions.get_session_list())
	M.answer_popup.border:set_text("top", "Auto chat", "center")
	local question = "I would like you to provide feedback to the current project and its structure. To explore the project and gather information about the structure you have a list of helper functions at your disposal that you can call. Do your own research with the tooling functions!\n"
		.. Tool.get_doc_string()
		.. "\n"
		.. 'You can safely assume that your current location in the file system "." is the root of the project.\n'
	local count = 1
	while count < 5 do
		Util.display_question(M.answer_popup.bufnr, question)
		local llm_question, finish = LLM.auto_ask(question, sessions.get_active())
		Util.display_answer(M.answer_popup.bufnr, llm_question)
		if not finish then
			question = Tool.call_if_valid(llm_question)
		else
			count = 100
		end
		count = count + 1
	end
	print("Autochat done")
end

vim.keymap.set({ "n" }, "<Leader>hu", function()
	if M.active_index == 0 then
		print("Cannot move there, limit reached")
		return
	end
	M.move_to_chat_with_index(M.active_index - 1)
end, { desc = "[H]elp from llama [U]pper chat" })

vim.keymap.set({ "n" }, "<Leader>hl", function()
	if M.active_index == #sessions.get_session_list() - 1 then
		print("Cannot move there, limit reached")
		return
	end
	M.move_to_chat_with_index(M.active_index + 1)
end, { desc = "[H]elp from llama [L]ower chat" })

function M.move_to_chat_with_index(index)
	local chat_list = sessions.get_session_list()
	assert(chat_list ~= nil, "Chat list can be empty but can never be nil")
	-- +1 because lua start with 1????
	local new_active_id = chat_list[index + 1].id
	sessions.set_active(new_active_id)
	Util.clear_buffer(M.answer_popup.bufnr)
	Util.write_full_conversation(M.answer_popup.bufnr, sessions.get_session_content(sessions.get_active()))
	M.update_chat_selection(sessions.get_session_list())
	local session_name = sessions.get_session_name(sessions.get_active())
	M.answer_popup.border:set_text("top", session_name, "center")
end

function M.full_ask_question(question)
	local response = LLM.ask(question, utils.get_new_session())
	Util.display_question(M.answer_popup.bufnr, question)
	Util.display_answer(M.answer_popup.bufnr, response)
end

M.question_input:map("n", "<Esc>", function()
	M.layout:unmount()
	M.is_displaying_w = false
end, { noremap = true })

function M.force_show_chat_window()
	M.layout:mount()()
	M.is_displaying_w = true
end

function M.toggle_chat_window()
	if M.is_displaying_w then
		M.is_displaying_w = false
		M.layout:hide()
	else
		M.layout:mount()
		LLM.start_new_ask_session()
		M.update_chat_selection(sessions.get_session_list())
		M.is_displaying_w = true
	end
end

function M.refactor()
	-- hide chat
	if M.is_displaying_w then
		M.toggle_chat_window()
	end
	local selection_position, selection_content = Util.capture_visual_selection()
	local input = Input({
		position = "50%",
		size = {
			width = "50%",
		},
		border = {
			style = "single",
			text = {
				top = "Refactor prompt",
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		prompt = "> ",
		default_value = "",
		on_close = function()
			print("Input Closed!")
		end,
		on_submit = function(value)
			local answer = LLM.refactor(value, selection_content)
			Util.replace_range(selection_position, answer)
			print("Refactor done")
		end,
	})
	input:mount()

	-- unmount component when cursor leaves buffer
	input:on(event.BufLeave, function()
		input:unmount()
	end)
end

return M
