# Measuring the speed of the parser

### Parsing the same file 1000 times
This is a very simple but still useful benchmark to measure how much time it takes to parse an exo.

Build in release mode
```sh
cargo build --release
```

Use `hyperfine` to benchmark the binary
```sh
> hyperfine ./target/release/parser-speed
Benchmark 1: ./target/release/parser-speed
  Time (mean ± σ):      39.0 ms ±   3.3 ms    [User: 20.2 ms, System: 18.6 ms]
  Range (min … max):    34.3 ms …  47.7 ms    79 runs
```

### TODO
Continue with more testing and building graphs to know when the parser is improving.
