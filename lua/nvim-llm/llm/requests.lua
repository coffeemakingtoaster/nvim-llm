local Curl = require("plenary.curl")

local M = {}

function M.do_request(question)
	local api_key = os.getenv("OPENAI_API_KEY")

	if not api_key then
		print(api_key)
		return "No API Key Set -> AI cannot answer"
	end

	local body = vim.fn.json_encode({
		model = "gpt-3.5-turbo",
		messages = {
			{ role = "user", content = question },
		},
	})

	local response = Curl.post("https://api.openai.com/v1/chat/completions", {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = "Bearer " .. api_key,
		},
		body = body,
	})

	if response.status ~= 200 then
		error("OpenAI API request failed with status " .. response.status .. ": " .. response.body)
	end

	local data = vim.fn.json_decode(response.body)
	local answer = data.choices and data.choices[1] and data.choices[1].message and data.choices[1].message.content
	if not answer then
		error("Unexpected response format from OpenAI API")
	end

	return vim.trim(answer)
end

return M
