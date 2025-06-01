local Curl = require("plenary.curl")
local utils = require("nvim-llm.llm.utils")

local M = {}

function M.do_request(conversation)
	local prompt = utils.build_prompt(conversation)

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

	return vim.trim(answer)
end

function M.do_raw_request(question)
	local response = Curl.post("http://localhost:11434/api/generate", {
		headers = {
			["Content-Type"] = "application/json",
		},
		body = vim.fn.json_encode({
			model = "llama3",
			prompt = question,
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

	return vim.trim(answer)
end

return M
