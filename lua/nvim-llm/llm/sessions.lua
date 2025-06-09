local utils = require("nvim-llm.llm.utils")
local requests = require("nvim-llm.llm.requests")
local M = {}

M.conversations = {}
M.conversation_names = {}

M.active_id = nil

function M.get_session_name(session_id)
	return M.conversation_names[session_id]
end

function M.update_session_name(session_id)
	if not M.conversations[session_id] then
		print("Could not summarize unknown session id")
		return ""
	end

	local prompt = utils.build_prompt(M.conversations[session_id])

	local summary = requests.do_raw_request(
		prompt
			.. "Please summarize the topic of our conversation in 3 words. Answer only with these 3 words and nothing else"
	)
	M.conversation_names[session_id] = summary
	return summary
end

function M.get_session_content(session_id)
	return M.conversations[session_id]
end

function M.append_session_content(session_id, role, content)
	if not M.conversations[session_id] then
		M.conversations[session_id] = {}
	end
	table.insert(M.conversations[session_id], { role = role, content = content })
end

function M.set_active(session_id)
	M.active_id = session_id
	if not M.conversation_names[session_id] then
		M.conversation_names[session_id] = "New Chat"
	end
end

function M.get_by_name(name)
	for i, v in ipairs(M.conversation_names) do
		if v == name then
			return i
		end
	end
	return ""
end

function M.get_active()
	return M.active_id
end

function M.delete_session(id)
	assert(id ~= M.active_id, "Cannot delete active session")
	M.conversation_names[id] = nil
	M.conversations[id] = nil
end

function M.get_session_list()
	local res = {}
	for id in pairs(M.conversation_names) do
		if id ~= M.active_id and M.conversations[id] == nil then
			goto continue
		end
		table.insert(res, { name = M.conversation_names[id], id = id, is_active = id == M.active_id })
		-- I know gotos are not that smart...but I wanted to use one at least once :)
		::continue::
	end
	return res
end

return M
