local Requests = require("nvim-llm/llm/requests")

local M = {}

M.session_id = ""

local trackedFiles = {}

function M.ask(question)
	local answer, session_id = Requests.do_request(question, M.session_id)
	if string.len(M.session_id) == 0 then
		M.session_id = session_id
	end
	local summary = Requests.get_session_name(M.session_id)
	return answer, summary
end

function M.refactor(prompt, currentSection)
	local fullPrompt = "Refactor the following codeblock according to this prompt: "
		.. prompt
		.. " .Only respond in the new and refactored source code, do not provide explanation or wrap it in a markdown codeblock! The source code is:\n"
		.. currentSection
	local answer, _ = Requests.do_request(fullPrompt, "")
	return answer
end

return M
