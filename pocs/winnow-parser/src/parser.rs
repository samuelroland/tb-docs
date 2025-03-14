// Winnow based parser

use crate::ds::Block;
use crate::ds::{McqExo, ParseError, ParseResult, Position, range_at};
use pretty_assertions::{assert_eq, assert_ne};
use winnow::Parser;
use winnow::Result;
use winnow::ascii::line_ending;
use winnow::ascii::multispace0;
use winnow::ascii::space0;
use winnow::combinator::separated_pair;
use winnow::combinator::{delimited, preceded};
use winnow::token::take_till;
use winnow::token::take_until;
use winnow::token::take_while;

fn extract_comment<'a>(raw: &'a mut &str) -> Result<&'a str> {
    preceded("//", take_till(1.., ['\n'])).parse_next(raw)
}

#[test]
fn comment_can_be_extracted() {
    let mut given = "//hey there";
    assert_eq!(extract_comment(&mut given).unwrap(), "hey there")
}

fn parse_prefixed_line<'a>(prefix: &str, raw: &'a mut &str) -> Result<(&'a str, &'a str)> {
    separated_pair(prefix, " ", take_until(1.., "\n")).parse_next(raw)
}

// fn parse_as_ast<'a>(raw: &'a mut &str) -> Vec<Block<'a>> {}

pub fn parse_mce_exo<'s>(input: &mut &'s str) -> Result<ParseResult> {
    let mut title = String::default();
    let mut title_found = false;
    let mut options = Vec::new();
    let mut errors = Vec::new();
    let mut correct_option_index = 0;

    // match parse_prefixed_line("exo", input) {
    //     Ok(("exo", t)) => {
    //         title = t.to_string();
    //     }
    //     Err(e) => {}
    // }
    Ok(ParseResult {
        exo: McqExo {
            title,
            options,
            correct_option_index,
        },
        errors,
    })
}

// impl std::str::FromStr for McqExo {
//     fn from_str(input: &str) -> Result<Self, Self::Err> {
//         parseexo
//             .map(Hex)
//             .parse(input)
//             .map_err(|e| anyhow::format_err!("{e}"))
//     }
// }
//
pub fn parse_exo(raw: &str) -> ParseResult {}

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
