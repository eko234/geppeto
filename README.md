# geppeto
Makes your editor a "real boy", I think it was the fairy tho, but idfc.

## Installation
Add this to your kakrc
``` kak
plug "eko234/geppeto" do %{ go install }
```
or just run `go install` manually from within the plugin directory.


## Configuration
In the configuration you should define the fifos for the plugin to work
``` kak
plug "eko234/geppeto" config %{
  set-option global chatinfifo "~/chatin"
  set-option global chatoutfifo "~/chatout"
  start-geppeto
}
```

## Usage
you can use

```
opengpt: to connect to the output fifo

gpt: to write to input fifo to interact with the chat, this function will take your prompt, and if you have a selection bigger than 1, it will append it to your prompt to ease the interaction with the chat
```
