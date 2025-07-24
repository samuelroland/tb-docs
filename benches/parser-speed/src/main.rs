use std::fs::read_to_string;

use plx_dy::parse_exo;

fn main() {
    for i in 1..1000 {
        print!("{i} ");
        let content = read_to_string("exo.dy").unwrap();
        dbg!(parse_exo(&Some("exo.dy".to_string()), &content));
    }
}
