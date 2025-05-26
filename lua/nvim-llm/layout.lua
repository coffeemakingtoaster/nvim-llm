local M = {}
local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event
local LLM = require("nvim-llm.llm")
local Util = require("nvim-llm.utils")
local prompt = "> "

M.is_displaying_w = false

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
	for _, chat in ipairs(chat_list) do
		table.insert(lines, chat)
	end

	local bufnr = M.chat_selection.bufnr
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)

	-- Apply highlight to the first line
	vim.api.nvim_buf_add_highlight(bufnr, -1, "answerpurple", 0, 0, -1)

	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

vim.keymap.set({ "n", "i" }, "<Enter>", function()
	local value = string.sub(vim.api.nvim_get_current_line(), vim.fn.strwidth(prompt) + 1)
	local response, summary = LLM.ask(value)
	Util.display_question(M.answer_popup.bufnr, value)
	Util.display_answer(M.answer_popup.bufnr, response)

	M.answer_popup.border:set_text("top", summary, "center")

	vim.api.nvim_win_call(M.answer_popup.winid, function()
		vim.cmd("normal! G")
	end)

	-- clear input field
	vim.api.nvim_set_current_line("")

	M.update_chat_selection({ summary })
end, { buffer = M.question_input.bufnr })

function M.full_ask_question(question)
	local response = LLM.ask(question)
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
