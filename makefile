model=llama3
	# use tmp file...idk if there is a better way
stamp=.pulled-$(model)

start-ollama:
	ollama serve & # start in background

$(stamp): start-ollama
	ollama pull $(model)
	touch $(stamp)

prepare-llama: $(stamp)

serve-llama: prepare-llama
	ollama run $(model)

clean:
	rm -f .pulled-*
