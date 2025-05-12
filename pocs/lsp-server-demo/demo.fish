#!/bin/fish
# Demo to execute a LSP conversation, that's not very usable manually by copy pasting
# as the line break symbol is \r\n not just \n as entered by copy paste or by enter on my Linux machine
# To run this script you need to have Fish installed and run `fish demo.fish`

# Utils
# Easy printing of colored text, use -d for diminued mode
function color
    set args $argv && if [ "$argv[1]" = -d ]
        set_color -d
        set args $argv[2..]
    end && set_color $args[1] && echo $args[2..] && set_color normal
end

# Compute message length + Send on stdout with JSON-RPC header and print to sdout
function send
    set json $argv
    set length (string length "$json  ") # the 2 extra space make +2 for the last \r\n, they are mandatory -> it will panic otherwise with "No Content-Length" (which is very confusing)
    set header "Content-Length: $length\r\n\r\n"
    set out "$header$json\r\n"
    color green -n -e "\nCLIENT: " 1>&2
    printf "$header" 1>&2
    set_color normal 1>&2
    # echo "$json" | jq -r -c 1>&2 # doesnt work with fold -w in svgshot...
    echo "$json" 1>&2
    color yellow -e -n "SERVER: " 1>&2
    printf "$out" # sending to client after having printed "SERVER" to make sure this label is before the response
end

# Run the scenario with sleep and send commands
begin
    sleep 1
    send '{"jsonrpc": "2.0", "method": "initialize", "id": 1, "params": {"capabilities": {}}}'
    sleep 2
    send '{"jsonrpc": "2.0", "method": "initialized", "params": {}}'
    sleep 1
    send '{"jsonrpc": "2.0", "method": "textDocument/definition", "id": 2, "params": {"textDocument": {"uri": "file///tmp/test.rs"}, "position": {"line": 7, "character": 23}}}'
    sleep 1
    send '{"jsonrpc": "2.0", "method": "shutdown", "id": 3, "params": null}'
    sleep 1
    send '{"jsonrpc": "2.0", "method": "exit", "params": null}'
    # WARNING: if you continue, make sure to manage IDs correctly !
    echo 1>&2
    echo 1>&2
end | cargo run -q
