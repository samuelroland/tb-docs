# docsgen
A small program to generate documentation for the protocol dynamically. It solve a few problems of painful documentation generation.

1. Instead of writing JSON messages by hand for the report, I export them from Rust directly.
1. Instead of manually exporting PlantUML diagram, just export them with a local server
1. Generate highlighting with Tree-Sitter of all `.dy` files under `../syntax/` as SVG + generate the output as SVG of `plx parse thisfile.dy`

## How to run
```sh
cd report/docsgen
cargo run
```

Run a local PlantUML server with Docker or change `docsgen/main.rs` to point to another URL or port.
```sh
docker run -p 5076:8080 --restart unless-stopped -d plantuml/plantuml-server
```

## How to update
From time to time, when the protocol change, we need to pull changes from PLX, fix build errors if any, add new messages or errors types manually.

Currently, we use the `live` branch, this will be changed later.
```toml
plx = { git = "https://github.com/samuelroland/plx", branch = "live" }
```

```sh
cd report/docsgen
cargo update plx # make sure we are at the latest commit from PLX
cargo run
```

## The results
Files are generated under `report/protocol/messages` folder. Here is the example of the generated tree. Notice teh `messages.typ` to be imported in `protocol.typ`.
```sh
protocol> tree
.
├── diagrams
│   ├── session.puml
│   ├── session.svg
│   ├── training.puml
│   └── training.svg
├── messages
│   ├── Action-GetSessions.json
│   ├── Action-JoinSession.json
...
│   └── messages.typ
└── protocol.typ
```
