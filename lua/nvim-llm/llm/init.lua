local Requests = require("nvim-llm/llm/requests")

local M = {}

function M.ask(question)
	return Requests.do_request(question)
end

return M
