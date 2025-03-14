// Basic hand-made naive parser and very specific to MCQ syntax given in pocs/README.md
// This is dirty code to get a sense of what a manual parser process
// This will be used by the Language server to allow interactive testing

use std::fs::read_to_string;

mod ds;
mod parser;

fn main() {
    let content = read_to_string("test.dy").expect("File test.dy should be present");
    let result = parser::parse_exo(&content);

    println!("Parsing result is");
    dbg!(&result);

    println!("Printing errors definitions");
    for err in result.errors {
        println!("- {}", err);
    }
}
