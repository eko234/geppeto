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
my kakrc configuration for geppeto looks like this

``` kak
plug "eko234/geppeto" do %{
  go install
} config %{
  geppetoreifywith mykeyagain...
  map global user i ": gpt "
}
```

## Usage
Just use `gpt` to write to input fifo to interact with the chat, this function will take your prompt, and if you have a selection bigger than 1, it will append it to your prompt to ease the interaction with the chat, it will get you to the chat buffer if you are using a single client, if you have a toolsclient associated with your session it will try to use
that

## Notes
you can also use the option `geppetoprogram` to change it to something different in case you are crazy or have problems installing it, for example a docker script or
directly running it with go like `go run /path/to/gepetto/main.go`.

## Caveats
right now I can't think of a way to gracefully handle the processes, you will only spawn a geppeto process once per kakoune session only when you use the gpt command, after that
the process is reused for that session, each kakoune session has his own geppeto process asociated, so if you come with a way to handle this better go ahead and invoke me, right
now you should kill the geppeto processes by hand, I just do `pgrep geppeto | xargs kill` when I'm done, usually I never am, so they just live there happily.
