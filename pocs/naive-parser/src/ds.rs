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
    TooMuchCorrectOptions(Range), // range of the second option flag "#ok"
    NoCorrectOption(Range),       // range of the "opt" prefix
    InvalidLine(Range),           // range of the whole line
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
