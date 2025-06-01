local guards = require("nvim-llm.tools.guards")
local M = {}

function M.get_doc_string()
	return "-`get_file_content(path)` returns the file content for the given filepath. This accepts relative file paths.\n"
end

-- primitive way of solving this -> rag would be smarter but this should work for now
function M.get_file_content(path)
	if not guards.is_within_root(path) then
		return "Path is outside the current project."
	end
	local file = io.open(path, "r")
	if not file then
		return "No file under this path"
	end

	local content = file:read("*a")
	file:close()
	return content
end

return M
