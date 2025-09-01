/// Simple client implementation of the live protocol, with the async approach
use std::fmt::Display;

use std::net::TcpStream;

use futures_util::SinkExt;
use tokio::select;
use tokio::sync::mpsc::{self, UnboundedReceiver, UnboundedSender, unbounded_channel};
use tokio_stream::StreamExt;
use tokio_tungstenite::tungstenite::Message;
use tokio_tungstenite::{WebSocketStream, tungstenite::stream::MaybeTlsStream};
use url::Url;

use plx_core::live::{
    protocol::{Action, ClientNum, Event, ExoCheckResult, LiveProtocolError, Session},
    server::{
        PROTOCOL_VERSION, QUERYSTRING_LIVE_CLIENT_ID_FIELD, QUERYSTRING_LIVE_PROTOCOL_VERSION_FIELD,
    },
};
use tokio_tungstenite::tungstenite;

type Ws = WebSocketStream<MaybeTlsStream<TcpStream>>;
pub struct AsyncLiveClient {
    /// A transmitter where we can send Action for the server
    pub(super) send: UnboundedSender<Action>,
    /// All events bac
    pub(super) recv: UnboundedReceiver<Event>,

    client_num: Option<ClientNum>,
}

#[derive(Debug)]
pub enum ProtocolError {
    Live(LiveProtocolError),
    Network(Box<tungstenite::Error>),
    UnexpectedMsg(String),
}

impl Display for ProtocolError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(
            match self {
                ProtocolError::Live(live_protocol_error) => {
                    format!("Live protocol error: {live_protocol_error}")
                }
                ProtocolError::Network(error) => format!("Network error: {error}"),
                ProtocolError::UnexpectedMsg(text) => {
                    format!("Unexpected message received from the server: {text}")
                }
            }
            .as_ref(),
        )
    }
}

impl AsyncLiveClient {
    pub async fn connect(
        domain: &str,
        port: u16,
        client_id: String,
    ) -> Result<AsyncLiveClient, std::io::Error> {
        let domain = domain.to_string();

        let (send_tx, mut send_rx) = unbounded_channel::<Action>();
        let (recv_tx, recv_rx) = unbounded_channel::<Event>();

        let link = format!("ws://{domain}:{port}");
        let url = Url::parse_with_params(
            &link,
            &[
                (QUERYSTRING_LIVE_CLIENT_ID_FIELD, client_id.as_ref()),
                (QUERYSTRING_LIVE_PROTOCOL_VERSION_FIELD, PROTOCOL_VERSION),
            ],
        )
        .unwrap();
        let (mut socket, _) = tokio_tungstenite::connect_async(url.to_string())
            .await
            .unwrap();
        tokio::spawn(async move {
            loop {
                select! {
                    // Read messages from socket and forward them
                    ws_msg = socket.next() => {
                        if let Some(Ok(ws_msg)) = ws_msg {
                            // println!("LiveClient: got {ws_msg:?}");
                            match ws_msg.into_text().ok().and_then(|txt| Event::try_from(txt).ok()) {
                                    Some(event) => {
                                        let _ = recv_tx.send(event.clone());
                                    }
                                    None => {
                                        eprintln!("Failed to parse event from ws_msg");
                                        continue;
                                    }
                                }
                        }
                    }
                    // Read actions to sent into socket
                    action = send_rx.recv() => {
                        if let Some(action) = action {
                            let msg = action.try_into();
                            if let Ok(msg) = msg {
                                let _ = socket.send(Message::Text(msg)).await;
                            }
                        } else {
                            break;
                        }
                    }
                }
            }
        });

        let client = AsyncLiveClient {
            send: send_tx,
            recv: recv_rx,
            client_num: None,
        };

        Ok(client)
    }

    pub async fn disconnect(self) {
        // just do nothing, let the struct and self.mp drop to close the self.mp.send
        // on the other end the receiver.recv() will return none which should stop the Splitter
        // and at the same time close the websocket on drop
    }

    /// Just sending a Msg on the socket
    pub async fn send_msg(&mut self, action: Action) {
        // println!("Sending: {action:?}");
        self.send.send(action).unwrap();
    }

    pub async fn wait_on_next_event(&mut self) -> Option<Event> {
        self.recv.recv().await
    }

    /// Create a new session
    pub async fn start_session(&mut self, name: &str, group_id: &str) -> Result<Session, String> {
        self.send_msg(Action::StartSession {
            name: name.to_string(),
            group_id: group_id.to_string(),
        })
        .await;
        let event = self.wait_on_next_event().await;
        if let Some(Event::SessionJoined(client_num)) = event {
            self.client_num = Some(client_num);
            Ok(Session {
                name: name.to_string(),
                group_id: group_id.to_string(),
            })
        } else {
            Err(format!("{event:?}"))
        }
    }

    /// Create a new session
    pub async fn stop_session(&mut self) {
        self.send_msg(Action::StopSession).await;
    }

    /// Join a session
    pub async fn join_session(&mut self, name: &str, group_id: &str) -> Result<Session, String> {
        self.send_msg(Action::JoinSession {
            name: name.to_string(),
            group_id: group_id.to_string(),
        })
        .await;
        if let Some(Event::SessionJoined(client_num)) = self.wait_on_next_event().await {
            println!("Joined session '{name}'");
            self.client_num = Some(client_num)
        }
        Ok(Session {
            name: name.to_string(),
            group_id: group_id.to_string(),
        })
    }

    /// Send a file content after a change
    pub async fn send_file(&mut self, file: String, content: String) {
        self.send_msg(Action::SendFile {
            path: file,
            content,
        })
        .await;
    }

    /// Send a check result
    pub async fn send_result(&mut self, check_result: ExoCheckResult) {
        self.send_msg(Action::SendResult { check_result }).await;
    }

    /// Send a check result
    pub async fn send_exo_switch(&mut self, path: String) {
        self.send_msg(Action::SwitchExo { path }).await;
    }

    /// Get all available session for a given group id
    pub async fn get_sessions(&mut self, group_id: String) -> Result<Vec<Session>, String> {
        self.send_msg(Action::GetSessions { group_id }).await;
        let e = self.wait_on_next_event().await;
        if let Some(Event::SessionsList(list)) = e {
            return Ok(list);
        }
        Err("Couldn't get sessions list".to_string())
    }
}
