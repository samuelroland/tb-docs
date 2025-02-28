// Basic hand-made naive parser and very specific to MCQ syntax given in pocs/README.md
// This is dirty code to get a sense of what a manual parser process
// This will be used by the Language server to allow interactive testing

#[derive(Eq, PartialEq, PartialOrd, Debug)]
struct McqExo {
    title: String,
    options: Vec<String>,
    correct_option_index: u8,
}

fn parse_exo(raw: &str) -> McqExo {
    let mut title = String::default();
    let mut options = Vec::new();
    let mut correct_option_index = 0;
    let mut options_started = false;
    let mut correct_option_found = false;
    let mut current_option_index = 0;
    for line in raw.lines() {
        if line.starts_with("//") {
            continue;
        }

        if line.starts_with("exo") {
            title = line.strip_prefix("exo ").unwrap().to_string();
            continue;
        }

        if line.starts_with("opt") {
            options_started = true;
            continue;
        }

        if line.starts_with("- ") && options_started {
            let mut item = line.strip_prefix("- ").unwrap().trim();
            if item.starts_with("#ok ") {
                item = item.strip_prefix("#ok ").unwrap();
                correct_option_found = true;
                correct_option_index = current_option_index;
            }
            options.push(item.to_string());
            current_option_index += 1;
            continue;
        }
    }

    println!("{correct_option_found}");
    McqExo {
        title,
        options,
        correct_option_index,
    }
}

#[test]
fn test_parse_fish_mcq_question() {
    let raw = "// Basic warmup exo
exo What is Fish ?
opt
- An animal in water
- #ok Friendly Interactive Shell
- Yet another geek joke";

    let fish_exo = McqExo {
        title: "What is Fish ?".to_string(),
        options: vec![
            "An animal in water".to_string(),
            "Friendly Interactive Shell".to_string(),
            "Yet another geek joke".to_string(),
        ],
        correct_option_index: 1,
    };
    assert_eq!(parse_exo(raw), fish_exo);
}

fn main() {
    println!("Hello, world!");
}
