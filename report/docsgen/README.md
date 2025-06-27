# docsgen
A small program to generate documentation for the protocol dynamically. It solve a few problems of painful documentation generation.

1. Instead of writing JSON messages by hand for the report, I export them from Rust directly.
1. Instead of manually exporting PlantUML diagram, just export them with a local server

## How to run
```sh
cd report/docsgen
cargo run
```

Run a local PlantUML server with Docker or change `docsgen/main.rs` to point to another URL or port.
```sh
docker run -p 5076:8080 --restart unless-stopped -d plantuml/plantuml-server
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
│   ├── Action-LeaveSession.json
│   ├── Action-SendFile.json
│   ├── Action-SendResult.json
│   ├── Action-StartSession.json
│   ├── Action-StopSession.json
│   ├── Event-Error-0.json
│   ├── Event-Error-1.json
│   ├── Event-Error-2.json
│   ├── Event-Error-3.json
│   ├── Event-Error-4.json
│   ├── Event-ForwardFile.json
│   ├── Event-ForwardResult.json
│   ├── Event-SessionJoined.json
│   ├── Event-SessionsList.json
│   ├── Event-SessionStarted.json
│   ├── Event-SessionStopped.json
│   ├── Event-Stats.json
│   └── messages.typ
└── protocol.typ
```
