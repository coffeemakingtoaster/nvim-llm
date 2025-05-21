# Nvim llm

Small and simple way to talk to chatgpt in nvim.
This has been done before, this has been done by people a lot more experienced with nvim than me....I just wanted to play around with nvim plugin development.

This is not complete or meant to be used by anyone else but me :)


## Default keybinds

Leader+h+c -> Open chat window

Leader+h+e -> Ask chatgpt to explain selected codeblock (requires visual mode)

All chatgpt requests rely on the `OPENAI_API_KEY` env var being set.
