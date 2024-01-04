
use colored::Colorize;
use clap::{command, Arg};

// Colors - this is how you can add colors 
// static YELLOW: &str = "\x1b[93m";
// static WHITE: &str = "\x1b[0m";

// struct Args {

// }

fn main() {

    let matches = command!()
        .arg(Arg::new("name").short('n').long("name"))
        .get_matches();

    println!("name: {:?}", matches.get_one::<String>("name"));

    // usage()
}

fn usage() {
    println!("{}", "ERROR: Script requires the following inputs:".red());
    let options = "
    -f: find tag
    -t: tag for ansible (DEFAULT: all)
    -i: get info for an aggregate tag (tags with multiple packages. e.g. macos-cli, macos-infra)
    -a: enable ask_become_pass";
    println!("{}", options.blue());

    let usage: &str = "\nUsage:
    rdoi # will display all available tags
    rdoi -t zsh -a
    rdoi -t meld,broot
    rdoi -f macos
    ";
    println!("{}", usage.yellow());
}


