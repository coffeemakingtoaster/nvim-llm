local M = {}

function M.get_new_session()
	local res = ""
	for i = 1, 64 do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function M.build_prompt(history)
	local prompt = ""
	for _, msg in ipairs(history) do
		if msg.role == "user" then
			prompt = prompt .. "User: " .. msg.content .. "\n"
		else
			prompt = prompt .. "Assistant: " .. msg.content .. "\n"
		end
	end
	prompt = prompt .. "Assistant: "
	return prompt
end

return M
