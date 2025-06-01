# Nvim llm

A small and simple way to talk to llamas in Neovim.
This has been done before, by people much more experienced with Neovim than I am. I simply wanted to play around with Neovim plugin development.

This is not complete or intended for use by anyone else but me. The codebase also needs a major cleanup.

## Quick start

Install extension.

Use `make serve-llama` to serve the model locally.

## Default keybinds

Leader+h+c -> Open chat window

Leader+h+e -> Ask llama to explain selected codeblock (requires visual mode)

## Dependencies

Relies on:

- curl
- make
- [ollama](https://ollama.com/)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim/tree/main)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim/)
