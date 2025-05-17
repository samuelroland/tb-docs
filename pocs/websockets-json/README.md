# A POC of Websockets communication with JSON messages in Rust

This POC is using the `tungstenite` crate.

To build the POC
```sh
cargo build
```


To run the POC, you needs 3 terminal windows. Follow this order to start the 3 processes:
1. Run `cargo run -q server`
1. Run `cargo run -q teacher`
1. Run `cargo run -q student`
1. At this point, you should see the check result behind sent from the `student` to the `teacher` every 2 seconds. The output is checked against `fake-exo/compare_output.txt`.

You can then edit the `fake-exo/src/main.rs` to test the 4 supported cases
- with the default code, you will get a wrong output
- a compilation error
- an execution error (put `exit(2);`)
- a correct output with the correct code
    ```rust
    fn main() {
        println!("Hello {} !", std::env::args().nth(1).unwrap());
    }
    ```
