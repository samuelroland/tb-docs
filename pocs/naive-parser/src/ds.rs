use std::fmt::Display;

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
// 1. A missing or empty title is not authorized (the `exo` key must be found and trimmed value should not be "")
// 1. Only one correct option is accepted, not less and not more
// 1. Double keyes is incorrect
// 1. A line that starts with something else that a known key or a dash or `//` is invalid
#[derive(Eq, PartialEq, PartialOrd, Debug, Clone, Ord)]
pub enum ParseError {
    EmptyLine(Position),
    TitleMissing(Position),
    TitleEmpty(Range),            // range of "exo" key
    TooMuchCorrectOptions(Range), // range of the second option property ".ok"
    NoCorrectOption(Range),       // range of the "opt" key
    InvalidLine(Range),           // range of the whole line
}

impl Display for ParseError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let text = match self {
            ParseError::EmptyLine(_) => "Empty lines are not accepted",
            ParseError::TitleMissing(_) => "The exo title is missing, add an `exo` key",
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
