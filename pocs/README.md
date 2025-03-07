# Proof of Concepts for a simplified DY syntax

## Goal
Experimenting with different libraries and technologies around parsing, LSP, syntax highlighting, IDE integration. The quality of code is not the priority, speed and experimentation is more important.

## POCs overview
1. Define a very basic syntax that has a 2 prefixes, 2 type of values (same line + list values), comment support, and a single boolean flag. Only one object is defined, no blank lines authorized. File name `fish.dy`.
1. `naive-parser`: Create a very basic hand-made parser in Rust (without any syntax abstractions, searching for literal prefixes) to parse this syntax into a Rust struct
1. Create another parser with chumsky, reuse tests suite, same features that `naive-parser`
1. Create another parser with Winnow, reuse tests suite, same features that `naive-parser`
1. Create a basic Language server to develop a few autocompletions, error diagnostics, hover prefixes definitions, a code action.
1. Write a TreeSitter grammar to support syntax highlighting, without any abstraction, straight to the point and install it in Neovim. See how it can be used via the tree-sitter CLI.

If I have the time
1. Try to integrate the Language server into VSCode
1. Try to do abstractions for other syntaxes
1. Try to generate TreeSitter syntaxes from abstractions without writing them by hand
1. Experiment with semantic highlighting

## Syntax
We would like to describe basic MCQ exos, this is inspired by current Delibay needs. This is not the definitive syntax ! In a file called `fish.dy`, we write this
```
// Basic warmup exo
exo What is Fish ?
opt
- An animal in water
- #ok Friendly Interactive Shell
- Yet another geek joke
```
We have a comment line starting with `//`. The keyword `exo` introduces a new exercise, it is followed by the title. Then `opt` introduces a list of options for this question. This list contains 3 string values starting with a `-`, the correct option is defined by a flag `#ok`, it must be present after the dash.

This MCQ exo must be parsed as this following Rust struct
```rust
struct McqExo {
    title: String,
    options: Vec<String>,
    correct_option_index: u8,
}
```

It we wanted to hardcode it, here is the struct usage

```rust
let fish_exo = McqExo {
    title: "What is Fish ?".to_string(),
    options: vec![
        "An animal in water".to_string(),
        "Friendly Interactive Shell".to_string(),
        "Yet another geek joke".to_string(),
    ],
    correct_option_index: 1,
};
```

If we wanted to export it in JSON, it would be

```json
{
    "title": "What is Fish ?",
    "options": [
        "An animal in water",
        "Friendly Interactive Shell",
        "Yet another geek joke"
    ],
    "correct_option_index": 1
}
```

### Possible errors
1. An empty line is forbidden, it should not block the parsing the raise an error in the IDE
1. A missing or empty title is not authorized (the `exo` prefix must be found and trimmed value should not be "")
1. Only one correct option is accepted, not less and not more
1. Double prefixes is incorrect
1. A line that starts with something else that a known prefix or a dash or `//` is invalid

## Retrospective of on naive-parser implementation
1. Basic parsing was very naive and very fast to implement
1. 
