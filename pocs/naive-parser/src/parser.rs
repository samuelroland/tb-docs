// Basic hand-made naive parser and very specific to MCQ syntax given in pocs/README.md
// This is dirty code to get a sense of what a manual parser process
// This will be used by the Language server to allow interactive testing

use crate::ds::*;
use pretty_assertions::{assert_eq, assert_ne};

fn range_at(line_index: u32, range_start: u32, range_length: u32) -> Range {
    Range {
        start: Position {
            line: line_index,
            character: range_start,
        },
        end: Position {
            line: line_index,
            character: range_start + range_length,
        },
    }
}

pub fn parse_exo(raw: &str) -> ParseResult {
    let mut title = String::default();
    let mut options = Vec::new();
    let mut errors = Vec::new();

    let mut correct_option_index = 0;
    let mut options_started = false;
    let mut correct_option_found = false;
    let mut current_option_index = 0;
    let mut opt_prefix_line = 0;

    for (idx, line) in raw.lines().enumerate() {
        let idx = idx as u32;
        if line.starts_with("//") {
            continue;
        }

        if line.starts_with("exo") {
            title = line.strip_prefix("exo ").unwrap().trim().to_string();
            if title.is_empty() {
                errors.push(ParseError::TitleEmpty(range_at(idx, 0, 3)));
            }
            continue;
        }

        if line.starts_with("opt") {
            opt_prefix_line = idx;
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

        if line.trim().is_empty() {
            errors.push(ParseError::EmptyLine(Position {
                line: idx,
                character: 0,
            }));
            continue;
        }

        errors.push(ParseError::InvalidLine(range_at(idx, 0, line.len() as u32)));
    }

    if !correct_option_found {
        errors.push(ParseError::NoCorrectOption(range_at(opt_prefix_line, 0, 3)));
    }

    ParseResult {
        exo: McqExo {
            title,
            options,
            correct_option_index,
        },
        errors,
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
    let result = parse_exo(raw);
    assert!(result.success());
    assert_eq!(result.exo, fish_exo);
}

#[test]
fn test_can_parse_more_complex_valid_exo() {
    let raw = "// Basic warmup exo
exo  A good question
// A few options
opt
- #ok a    \t
-     bbbbbbb
- c - and - and f
- #okayguys !
// That's done here #ok ! exo opt are ignored here
";

    let rnd_exo = McqExo {
        title: "A good question".to_string(),
        options: vec![
            "a".to_string(),
            "bbbbbbb".to_string(),
            "c - and - and f".to_string(),
            "#okayguys !".to_string(),
        ],
        correct_option_index: 0,
    };
    let result = parse_exo(raw);
    assert!(result.success());
    assert_eq!(result.exo, rnd_exo);
}

// ERRORS detection tests
#[test]
fn test_can_detect_some_errors() {
    let raw = "
exo     \t
opt
- Friendly Interactive Shell
- Yet another geek joke
oups";

    let fish_exo_wrong = McqExo {
        title: String::default(),
        options: vec![
            "Friendly Interactive Shell".to_string(),
            "Yet another geek joke".to_string(),
        ],
        correct_option_index: 0,
    };
    let result = parse_exo(raw);
    assert!(!result.success());
    assert_eq!(result.exo, fish_exo_wrong);

    let mut errors = result.errors.clone();
    errors.sort();
    let mut expected_errors = vec![
        ParseError::EmptyLine(Position {
            line: 0,
            character: 0,
        }),
        ParseError::TitleEmpty(range_at(1, 0, 3)),
        ParseError::NoCorrectOption(range_at(2, 0, 3)),
        ParseError::InvalidLine(range_at(5, 0, 4)),
    ];
    expected_errors.sort();
    assert_eq!(errors, expected_errors);
}
