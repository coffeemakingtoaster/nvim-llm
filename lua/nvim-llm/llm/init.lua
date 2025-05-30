local Requests = require("nvim-llm/llm/requests")
local sessions = require("nvim-llm.llm.sessions")
local utils = require("nvim-llm.llm.utils")

local M = {}

function M.start_new_ask_session()
	local id = utils.get_new_session()
	sessions.set_active(id)
	return id
end

function M.ask(question, session_id)
	-- if empty session id -> use active
	assert(
		session_id ~= nil,
		"session_id was nil. This should never happen if session handling is done correctly in GUI"
	)
	if string.len(session_id) == 0 then
		session_id = sessions.get_active()
	end
	sessions.append_session_content(session_id, "user", question)
	local answer = Requests.do_request(question, sessions.get_session_content(session_id))
	sessions.append_session_content(session_id, "assistant", answer)
	local summary = sessions.update_session_name(session_id)
	return answer, summary
end

local function is_done(answer)
	return string.find(answer, "!DONE!")
end

function M.auto_ask(question, session_id)
	-- if empty session id -> use active
	assert(
		session_id ~= nil,
		"session_id was nil. This should never happen if session handling is done correctly in GUI"
	)
	if string.len(session_id) == 0 then
		session_id = sessions.get_active()
	end
	question = question
		.. "\nAdd the text !DONE! to the very end of your message once your answer is final and you do not intend on calling any more tool functions."
	sessions.append_session_content(session_id, "user", question)
	local answer = Requests.do_request(question, sessions.get_session_content(session_id))
	sessions.append_session_content(session_id, "assistant", answer)
	local done = is_done(answer)
	-- remove I AM DONE if needed
	if done then
		answer = string.gsub(answer, "!DONE!", "")
	end
	return answer, done
end

function M.refactor(prompt, currentSection)
	local fullPrompt = "Refactor the following codeblock according to this prompt: "
		.. prompt
		.. " .Only respond in the new and refactored source code, do not provide explanation or wrap it in a markdown codeblock! The source code is:\n"
		.. currentSection
	local answer, _ = Requests.do_request(fullPrompt, {})
	return answer
end

return M
