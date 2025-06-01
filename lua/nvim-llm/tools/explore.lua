local guards = require("nvim-llm.tools.guards")
M = {}

local uv = vim.loop

function M.get_doc_string()
	return '-`get_recursive_dir_structure(path)` returns the directory and file structure recursively for a given path. This accepts relative paths so when unsure you can start with get_recursive_dir_structure(".")\n'
end

local function get_rec_dir(path, indent)
	if not guards.is_within_root(path) then
		return "Path is outside the current project."
	end
	local entries = {}

	local function scandir(dir)
		local fd = uv.fs_scandir(dir)
		if not fd then
			return
		end

		while true do
			local name, type = uv.fs_scandir_next(fd)
			if not name then
				break
			end

			table.insert(entries, { name = name, type = type })
		end
	end

	scandir(path)
	table.sort(entries, function(a, b)
		return a.name < b.name
	end)

	local lines = {}
	for _, entry in ipairs(entries) do
		local full_path = path .. "/" .. entry.name
		if entry.type == "directory" and entry.name ~= ".git" then
			table.insert(lines, indent .. entry.name)
			local sub_lines = get_rec_dir(full_path, indent .. indent)
			for s in sub_lines:gmatch("[^\r\n]+") do
				table.insert(lines, s)
			end
		else
			table.insert(lines, indent .. "- " .. entry.name)
		end
	end

	local res = table.concat(lines, "\n")
	return res
end

function M.get_recursive_dir_structure(path, indent)
	return get_rec_dir(path, indent)
end

return M
