# Nvim llm

Small and simple way to talk to llama in nvim.
This has been done before, this has been done by people a lot more experienced with nvim than me....I just wanted to play around with nvim plugin development.

This is not complete or meant to be used by anyone else but me :)

## Quick start

Install extension.

Use `make serve-llama` to serve the model locally.

## Default keybinds

Leader+h+c -> Open chat window

Leader+h+e -> Ask llama to explain selected codeblock (requires visual mode)

## Dependencies

Relies on:

- curl
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim/tree/main)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim/)
