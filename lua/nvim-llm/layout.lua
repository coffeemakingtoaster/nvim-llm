local M = {}
local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local LLM = require("nvim-llm.llm")
local Util = require("nvim-llm.utils")
local prompt = "> "

M.is_displaying_w = false
M.answer_popup = Popup({
	border = {
		style = "single",
		text = {
			top = "nvim-llm",
		},
	},
})
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
	prompt = prompt,
	default_value = "",
	on_submit = function(value)
		print("Input Submitted: " .. value)
	end,
})

M.layout = Layout(
	{
		position = "50%",
		size = {
			width = 150,
			height = 40,
		},
	},
	Layout.Box({
		Layout.Box(M.answer_popup, { size = "90%" }),
		Layout.Box(M.question_input, { size = {
			height = "10%",
		} }),
	}, { dir = "col" })
)

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

return M
