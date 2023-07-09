# geppeto
Makes your editor a "real boy", I think it was the fairy tho, but idfc.

## Installation
Add this to your kakrc
``` kak
plug "eko234/geppeto" do %{ go install }
```
or just run `go install` manually from within the plugin directory.

## Configuration
In the configuration you just need to call the function `geppetoreifywith`
to safely set the api key so no sketchy kakoune plugin writers could steal your
key from their nasty plugins.

I like to map user-i to ": gpt ", but you do whatever
``` kak
plug "eko234/geppeto" config %{
  geppetoreifywith <API KEY, yes I leaked mine writing this plugin>
  map global user i ": gpt "
}
```

## Usage
you can use
  - `opengpt`: to connect to the output fifo
  - `gpt`: to write to input fifo to interact with the chat, this function will take your prompt, and if you have a selection bigger than 1, it will append it to your prompt to ease the interaction with the chat


## Notes
you can also use the option `geppetoprogram` to change it to something different in case you are crazy or have problems installing it.
