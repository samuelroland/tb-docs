use std::{
    fmt::format,
    fs::read_to_string,
    net::TcpStream,
    path::{Path, PathBuf},
    process::{Command, Stdio, exit},
    str::FromStr,
    sync::{Arc, Mutex},
    thread::{self, sleep},
    time::Duration,
};

use colored::Colorize;
use serde::{Deserialize, Serialize};
use serde_json::Result;
use websocket::{
    ClientBuilder, CloseData, Message,
    sync::{Client, Server},
};

const TCP_SOCKET: &str = "127.0.0.1:9120";
const FAKE_EXO: &str = "fake-exo/";
const COMPARE_TXT_FILE: &str = "compare_output.txt";
const STUDENT_SENDING_CODE_FREQUENCY_MS: u64 = 2000;

#[derive(Serialize, Deserialize, Debug)]
enum ExoStatus {
    FailedBuild {
        stderr: String,
    },
    IncorrectOutput {
        stdout: String,
    },
    CorrectOutput,
    FailedExecution {
        stderr: String,
        stdout: String,
        status: Option<i32>,
    },
}
#[derive(Serialize, Deserialize, Debug)]
struct CheckResult {
    path: String,
    status: ExoStatus,
    code: String,
}

impl CheckResult {
    fn resume(&self) {
        println!(
            "Exo check on file {}, with given code:\n{}\n{}",
            self.path.blue(),
            self.code.trim().dimmed(),
            match &self.status {
                ExoStatus::FailedBuild { stderr } =>
                    format!("{}\n{}", "failed build with error".red(), stderr.dimmed()),
                ExoStatus::IncorrectOutput { stdout } =>
                    format!("{}\n{}", "Built but output is incorrect".purple(), stdout),
                ExoStatus::CorrectOutput => "Correct output !".green().to_string(),
                ExoStatus::FailedExecution {
                    stderr,
                    stdout,
                    status,
                } => format!(
                    "Program execution failed with status code {}\nstdout:\n{}\nstderr:\n{}",
                    status.unwrap_or(-1).to_string().purple(),
                    stdout,
                    stderr.bright_red()
                ),
            }
        );
    }
}

/// A quick and dirty way to run an exo check, to build and run the exo under
/// FAKE_EXO folder, if build passes, we run it and compare the output with
/// COMPARE_TXT_FILE content to verify the output
fn fake_exo_test() -> CheckResult {
    let base_path = PathBuf::from_str(FAKE_EXO).unwrap();
    let build_result = Command::new("cargo")
        .current_dir(&base_path)
        .args(vec!["build"])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .unwrap();
    let stdout = String::from_utf8(build_result.stdout).unwrap();
    let stderr = String::from_utf8(build_result.stderr).unwrap();

    let code_path = base_path.clone().join("src").join("main.rs");
    let compare_path = base_path.clone().join(COMPARE_TXT_FILE);
    let code_content = read_to_string(&code_path).unwrap();
    let compare_content = read_to_string(&compare_path).unwrap();

    // default case is failed build, let's explore other situations
    let mut exo_status = ExoStatus::FailedBuild { stderr };
    if build_result.status.success() {
        let run_result = Command::new("cargo")
            .current_dir(&base_path)
            .args(["run", "-q", "--", "Samuel"]) // -q is important to compare
            // only output from program, not the header printed by cargo run
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .output()
            .unwrap();
        let stdout = String::from_utf8(run_result.stdout).unwrap();
        let stderr = String::from_utf8(run_result.stderr).unwrap();
        if run_result.status.success() {
            if compare_content == stdout {
                exo_status = ExoStatus::CorrectOutput
            } else {
                exo_status = ExoStatus::IncorrectOutput { stdout }
            }
        } else {
            exo_status = ExoStatus::FailedExecution {
                stderr,
                stdout,
                status: run_result.status.code(),
            }
        }
    }

    CheckResult {
        path: code_path.to_str().unwrap().to_string(),
        status: exo_status,
        code: code_content,
    }
}

// This implementation is based on examples from the websocket crate
// https://docs.rs/websocket/latest/websocket/server/sync/type.Server.html
fn start_server() {
    let server = Server::bind(TCP_SOCKET).unwrap();
    println!("Server started on {TCP_SOCKET}");
    let student_socket: Arc<Mutex<Option<Client<TcpStream>>>> = Arc::new(Mutex::new(None));
    let teacher_socket: Arc<Mutex<Option<Client<TcpStream>>>> = Arc::new(Mutex::new(None));

    for connection in server.into_iter() {
        // Spawn a new thread for each connection.
        let student_socket_ref = student_socket.clone();
        let teacher_socket_ref = teacher_socket.clone();
        let mut client = connection.unwrap().accept().unwrap();

        let first_msg = client.recv_message().unwrap();
        if let websocket::OwnedMessage::Text(txt) = first_msg {
            match txt.as_str() {
                "student" => {
                    *student_socket_ref.lock().unwrap() = Some(client);
                    println!("Student connected, saved associated socket.");
                }
                "teacher" => {
                    *teacher_socket_ref.lock().unwrap() = Some(client);
                    println!("Teacher connected, saved associated socket.");
                }
                _ => (),
            }
        }

        // We finished the setup of the 2 socket
        if student_socket.lock().unwrap().is_some() && teacher_socket.lock().unwrap().is_some() {
            println!("student and teacher is connected !");
            break;
        }
    }

    println!("Listening on messages from student and forward to teacher");
    let mut teacher_socket_guard = teacher_socket.lock().unwrap();
    let mut student_socket_guard = student_socket.lock().unwrap();
    let teacher_client = teacher_socket_guard.as_mut().unwrap();
    let student_client = student_socket_guard.as_mut().unwrap();
    while let Some(msg) = student_client.recv_message().into_iter().next() {
        if let websocket::OwnedMessage::Text(txt) = msg {
            let _ = teacher_client.send_message(&Message::text(txt));
            println!("Forwarded one message to teacher");
        }
    }
}

fn start_student() {
    sleep(Duration::from_secs(1));
    let mut client = ClientBuilder::new(&format!("ws://{TCP_SOCKET}"))
        .unwrap()
        .connect_insecure()
        .unwrap();

    println!("Sending whoami message");
    let message = Message::text("student");
    client.send_message(&message).unwrap(); // Send message
    println!(
        "Starting to send code every {} ms, printing a dot + an emoji to indicate build status",
        STUDENT_SENDING_CODE_FREQUENCY_MS
    );

    loop {
        let check_result = fake_exo_test();
        let json = serde_json::to_string(&check_result).unwrap();
        println!("Sending another check result\n{}", json.dimmed());
        let _ = client.send_message(&Message::text(json));
        sleep(Duration::from_millis(STUDENT_SENDING_CODE_FREQUENCY_MS));
    }
}

fn start_teacher() {
    sleep(Duration::from_millis(500));
    let mut client = ClientBuilder::new(&format!("ws://{TCP_SOCKET}"))
        .unwrap()
        .connect_insecure()
        .unwrap();

    println!("Sending whoami message");
    let message = Message::text("teacher");
    client.send_message(&message).unwrap(); // Send message
    println!("Waiting on student's check results");
    while let Ok(msg) = client.recv_message() {
        match msg {
            websocket::OwnedMessage::Text(msg) => match serde_json::from_str::<CheckResult>(&msg) {
                Ok(check_result) => check_result.resume(),
                Err(e) => eprintln!(
                    "Received unknown message {}, trying to parse to CheckResult failed with {e}",
                    msg
                ),
            },
            websocket::OwnedMessage::Close(close_data) => {
                dbg!("Closed {}", close_data);
            }
            _ => (),
        }
    }
}

fn print_help_and_quit(error: &str) {
    eprintln!("Error: {error}");
    eprintln!("Usage: websockets-json student|teacher|server");
    exit(2);
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        print_help_and_quit("Missing first argument");
    }

    let first = &args[1];

    println!("{}", format!("Starting {} process...", first).red());
    match first.as_str() {
        "student" => start_student(),
        "teacher" => start_teacher(),
        "server" => start_server(),
        _ => println!("Incorrect first argument {first}"),
    }
}
