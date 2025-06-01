local M = {}

function M.is_within_root(given_path)
	local root = vim.loop.cwd()
	given_path = vim.fn.fnamemodify(given_path, ":p") -- absolute path
	root = vim.fn.fnamemodify(root, ":p")

	return given_path:sub(1, #root) == root
end

return M
