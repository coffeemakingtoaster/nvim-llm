local Explore = require("nvim-llm.tools.explore")
local retrieve = require("nvim-llm.tools.retrieve")

M = {}

function M.get_doc_string()
	return "The following is a list of valid functions you can use: \n"
		.. Explore.get_doc_string()
		.. retrieve.get_doc_string()
		.. "When accessing the function ONLY reply with the function name itself! No need for additional fluff, otherwise you will get an invalid response! String parameters must be wrapped in quotes"
end

function M.call_if_valid(name)
	local path = name:match('^get_recursive_dir_structure%("%s*(.-)%s*"%)$')
	if path ~= nil then
		return "The file system looks like this:\n" .. Explore.get_recursive_dir_structure(path, " ")
	end
	local file_path = name:match('^get_file_content%("%s*(.-)%s*"%)$')
	if file_path ~= nil then
		return "The file contents are:\n" .. retrieve.get_file_content(file_path)
	end

	return "Remember to only answer with the function call if you want to use a function!"
end

return M
