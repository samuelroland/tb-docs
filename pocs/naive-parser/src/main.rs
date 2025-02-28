use std::{env::args, fs::read_to_string};

#[derive(Eq, PartialEq, PartialOrd, Debug)]
struct McqExo {
    title: String,
    options: Vec<String>,
    correct_option_index: u8,
}

fn main() {
    let args = args();
    let content = read_to_string("fish.dy").unwrap();
    let fish_exo = McqExo {
        title: "What is Fish ?".to_string(),
        options: vec![
            "An animal in water".to_string(),
            "Friendly Interactive Shell".to_string(),
            "Yet another geek joke".to_string(),
        ],
        correct_option_index: 1,
    };
    println!("Hello, world!");
}
