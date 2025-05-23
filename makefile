model=llama3

start-ollama:
	ollama serve& # start in background

prepare-llama: start-ollama
	ollama pull $(model)

serve-llama: prepare-llama
	ollama run $(model)
