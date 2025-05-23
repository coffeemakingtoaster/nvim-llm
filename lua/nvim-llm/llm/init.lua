local Requests = require("nvim-llm/llm/requests")

local M = {}

M.session_id = ""

function M.ask(question)
	local answer, session_id = Requests.do_request(question, M.session_id)
	if string.len(M.session_id) == 0 then
		M.session_id = session_id
	end
	local summary = Requests.get_session_name(M.session_id)
	return answer, summary
end

return M
