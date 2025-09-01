// See README.md for details about this benchmark
use std::{thread::sleep, time::Duration};

use plx_core::live::{protocol::ExoCheckResult, server::DEFAULT_LIVE_PORT};
use rand::{Rng, RngCore};
use simpleclient::AsyncLiveClient;

mod simpleclient;

const DOMAIN: &str = "live.plx.rs";

const THOUSANDS_CHARS_LOREM_IPSUM : &str = "
Lorem ipsum dolor sit amet, consectetur adipiscing elit. In vitae sagittis nisl, at pretium purus. Quisque eu molestie ex. Cras vulputate mi a lorem tincidunt, sit amet ornare velit rutrum. Cras tempus quam turpis, nec egestas lacus tristique eget. Nam venenatis elit risus, ut porttitor augue porttitor pretium. Mauris rhoncus leo ut consequat sollicitudin. Ut ante erat, pulvinar nec ultrices sed, sagittis sit amet felis. Suspendisse tempor dui justo, at sagittis tortor ullamcorper vel. Duis aliquet aliquam ante eget rutrum. Pellentesque ac dignissim mauris. Suspendisse eget consectetur leo. Quisque tempor velit odio, mattis imperdiet magna vehicula vitae. Integer ut tortor ipsum. Aliquam mauris enim, cursus vel lorem a, gravida maximus dolor. Duis eu lorem metus.

Proin condimentum ligula leo, ut volutpat augue cursus a. Proin et scelerisque enim. Nunc eget sem id erat tincidunt lacinia sit amet ac lectus. Fusce rutrum tincidunt nisl consequat ultrices. Nam interdum nulla ut euismod.";

// Number of file saved per minutes
const MIN_SAVE_PER_MINUTE: u16 = 2;
const MAX_SAVE_PER_MINUTE: u16 = 20;
// Number of client to put in a live session
const MIN_CLIENT_PER_SESSION: u16 = 20;
const MAX_CLIENT_PER_SESSION: u16 = 60;

// It is going to create new live sessions while the total of connected clients is not above this minimum
const EXACT_TOTAL_CLIENTS_TO_REACH: u16 = 1000;

async fn spawn_new_follower(session_name: String, session_group_id: String, follower_id: String) {
    let mut follower = AsyncLiveClient::connect(
        DOMAIN,
        DEFAULT_LIVE_PORT,
        format!("client-id-{follower_id}",),
    )
    .await
    .unwrap();
    follower
        .join_session(&session_name, &session_group_id)
        .await
        .unwrap();

    let duration = Duration::from_secs(rand::rng().random_range(2..15));
    println!("{follower_id}: connected and waiting just {duration:?} at first");

    tokio::spawn(async move {
        // Wait just a bit before starting to
        // avoid having all clients starting and waiting on the same time at start
        tokio::time::sleep(duration).await;

        let sleep_time = Duration::from_secs(
            60 / rand::rng()
                .random_range(MIN_SAVE_PER_MINUTE.into()..(MAX_SAVE_PER_MINUTE as u64 - 10)),
        );
        loop {
            println!("{follower_id} after {sleep_time:?}: Sending code + check");
            follower
                .send_file(
                    "main.c".to_string(),
                    THOUSANDS_CHARS_LOREM_IPSUM.to_string(),
                )
                .await;
            follower
                .send_result(ExoCheckResult {
                    index: 3,
                    state: plx_core::live::protocol::CheckStatus::CheckFailed(
                        "oups not working fully".to_string(),
                    ),
                })
                .await;
            tokio::time::sleep(sleep_time).await;
        }
    });
}

async fn spawn_new_leader(session_name: &str, session_group_id: &str) {
    let mut leader = AsyncLiveClient::connect(DOMAIN, DEFAULT_LIVE_PORT, format!("SecretId{}", 1))
        .await
        .unwrap();
    leader
        .start_session(session_name, session_group_id)
        .await
        .unwrap();
    println!("Started session {session_name} on {session_group_id}");
    tokio::spawn(async move {
        leader.send_exo_switch("test".to_string()).await;
        let mut rng = rand::rng();
        tokio::time::interval(Duration::from_secs(
            60 / rng.random_range(MIN_SAVE_PER_MINUTE.into()..(MAX_SAVE_PER_MINUTE as u64 - 10)),
        ))
    });
}

async fn spawn_new_live_session(
    clients_number: u16,
    session_name: &str,
    session_group_id: &str,
    client_id_offset: u16,
) {
    spawn_new_leader(session_name, session_group_id).await; // this should wait on the leader to have the session created before starting followers !
    for i in 1..clients_number {
        let name = session_name.to_string();
        let group = session_group_id.to_string();
        tokio::spawn(async move {
            spawn_new_follower(name, group, format!("follower-{}", i + client_id_offset)).await;
        });
    }
}

#[tokio::main]
async fn main() {
    let mut total_clients = 0;
    let mut rng = rand::rng();
    while total_clients < EXACT_TOTAL_CLIENTS_TO_REACH {
        let mut clients_number = rng.random_range(MIN_CLIENT_PER_SESSION..MAX_CLIENT_PER_SESSION);
        if clients_number + total_clients > EXACT_TOTAL_CLIENTS_TO_REACH {
            clients_number = EXACT_TOTAL_CLIENTS_TO_REACH - total_clients;
        }
        let name = format!("name-test-{}", rng.next_u32());
        let group_id = format!("group-test-{}", rng.next_u32());
        spawn_new_live_session(clients_number, &name, &group_id, total_clients).await;
        total_clients += clients_number;
        println!(
            "Spawned new live session name = {name} and group_id = {group_id}, with {clients_number}"
        )
    }

    println!(
        "clients_number has reached EXACT_TOTAL_CLIENTS_TO_REACH ({EXACT_TOTAL_CLIENTS_TO_REACH}), {total_clients} have been spawned."
    );

    sleep(Duration::from_secs(300));
}
