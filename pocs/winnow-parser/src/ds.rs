use std::fmt::Display;

struct Property<'a>(&'a str);

struct ListItem<'a> {
    line: usize,
    content: &'a str,
    properties: Vec<Property<'a>>,
}

pub enum Block<'a> {
    // start of an entity, must be a single line but is described further by sub blocks
    Entity {
        line: usize,
        prefix: &'a str,
        content: &'a str,
        subs: Vec<Block<'a>>, // list of subblocks
    },
    SingleLine {
        line: usize,
        prefix: &'a str,
        content: &'a str,
    }, // line index + prefix + text
    List {
        line: usize,
        prefix: &'a str,
        items: Vec<ListItem<'a>>,
    }, // line index + prefix + list of tuple (line index + content + list of property)
    Comment(usize, &'a str), // line index + comment content
}

// Example of AST for this exo, with added prefix "exp" to show the difference between Start and
// SingleLine blocks
// // Basic warmup exo
// exo What is Fish ?
// opt
// - An animal in water
// - .ok Friendly Interactive Shell
// - Yet another geek joke
// exp because we are geeks
fn build() {
    // Example of imagined AST of above text
    let fish: Vec<Block> = vec![
        Block::Comment(0, "Basic warmup exo"),
        Block::Entity {
            line: 0,
            prefix: "exo",
            content: "What is Fish",
            subs: vec![
                Block::List {
                    line: 2,
                    prefix: "opt",
                    items: vec![
                        ListItem {
                            line: 3,
                            content: "An animal in water",
                            properties: vec![],
                        },
                        ListItem {
                            line: 3,
                            content: "Friendly Interactive Shell",
                            properties: vec![Property("ok")],
                        },
                        ListItem {
                            line: 3,
                            content: "Yet another geek joke",
                            properties: vec![],
                        },
                    ],
                },
                Block::SingleLine {
                    line: 6,
                    prefix: "exp",
                    content: "because we are geeks",
                },
            ],
        },
    ];
}

// Data structures
#[derive(Eq, PartialEq, PartialOrd, Debug)]
pub struct McqExo {
    pub title: String,
    pub options: Vec<String>,
    pub correct_option_index: u8,
}

// Inspired by LSP spec
#[derive(Eq, PartialEq, PartialOrd, Debug, Clone, Ord)]
pub struct Position {
    pub line: u32,
    pub character: u32,
}
#[derive(Eq, PartialEq, PartialOrd, Debug, Clone, Ord)]
pub struct Range {
    pub start: Position,
    pub end: Position,
}

// 1. An empty line is forbidden, it should not block the parsing the raise an error in the IDE
// 1. A missing or empty title is not authorized (the `exo` prefix must be found and trimmed value should not be "")
// 1. Only one correct option is accepted, not less and not more
// 1. Double prefixes is incorrect
// 1. A line that starts with something else that a known prefix or a dash or `//` is invalid
#[derive(Eq, PartialEq, PartialOrd, Debug, Clone, Ord)]
pub enum ParseError {
    EmptyLine(Position),
    TitleMissing(Position),
    TitleEmpty(Range),            // range of "exo" prefix
    TooMuchCorrectOptions(Range), // range of the second option property ".ok"
    NoCorrectOption(Range),       // range of the "opt" prefix
    InvalidLine(Range),           // range of the whole line
}

impl Display for ParseError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let text = match self {
            ParseError::EmptyLine(_) => "Empty lines are not accepted",
            ParseError::TitleMissing(_) => "The exo title is missing, add an `exo` prefix",
            ParseError::TitleEmpty(_) => "Given title is empty",
            ParseError::TooMuchCorrectOptions(_) => {
                "Found too much correct options, only one can be correct."
            }
            ParseError::NoCorrectOption(_) => {
                "No correct option found, please add `.ok` between the dash and the correct option text"
            }
            ParseError::InvalidLine(_) => {
                "This lines seems to be invalid, considering its position and start text."
            }
        };
        f.write_str(text)
    }
}

#[derive(Eq, PartialEq, PartialOrd, Debug)]
pub struct ParseResult {
    pub exo: McqExo,
    pub errors: Vec<ParseError>,
}

impl ParseResult {
    pub fn success(&self) -> bool {
        self.errors.is_empty()
    }
}

pub fn range_at(line_index: u32, range_start: u32, range_length: u32) -> Range {
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
