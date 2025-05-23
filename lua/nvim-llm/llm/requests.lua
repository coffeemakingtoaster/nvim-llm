local Curl = require("plenary.curl")

local M = {}

local conversations = {}

local function build_prompt(history)
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

function M.get_new_session()
	local res = ""
	for i = 1, 64 do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function M.get_session_name(session_id)
	if not conversations[session_id] then
		print("Could not summarize unknown session id")
		return ""
	end

	local prompt = build_prompt(conversations[session_id])

	local answer, _ = M.do_request(
		prompt
			.. "Please summarize the topic of our conversation in 3 words. Answer only with these 3 words and nothing else",
		""
	)
	return answer
end

function M.do_request(question, session_id)
	if string.len(session_id) == 0 then
		session_id = M.get_new_session()
	end
	conversations[session_id] = conversations[session_id] or {}
	table.insert(conversations[session_id], { role = "user", content = question })

	local prompt = build_prompt(conversations[session_id])

	local response = Curl.post("http://localhost:11434/api/generate", {
		headers = {
			["Content-Type"] = "application/json",
		},
		body = vim.fn.json_encode({
			model = "llama3",
			prompt = prompt,
			stream = false,
		}),
		timeout = "60000", -- 60 seconds because local llms may take a while
	})

	if response.status ~= 200 then
		error("Ollama API request failed with status " .. response.status .. ": " .. response.body)
	end

	local data = vim.fn.json_decode(response.body)
	local answer = data.response
	if not answer then
		error("Unexpected response format from Ollama API")
	end

	table.insert(conversations[session_id], { role = "assistant", content = answer })
	return vim.trim(answer), session_id
end

return M
