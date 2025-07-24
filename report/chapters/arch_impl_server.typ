#import "@preview/zebraw:0.5.5": zebraw
= Développement du serveur de session live <arch_impl_server>
Cette partie documente l'architecture et l'implémentation du serveur de session live, l'implémentation d'un client dans PLX et le protocole définit entre les deux.

Tout le code de cette partie a été développé sur le repository #link("https://github.com/samuelroland/plx"), voir `src/live` pour l'implémentation du serveur, voir `tests/live.rs` pour les tests de bout en bout voir l'intégration dans le dossier `desktop`, notamment le fichier `desktop/src/client.ts`. Le repository contient le CLI, PLX desktop et la librairie `plx-core` incluant l'implémentation du serveur.

La @high-level-arch montre la vue d'ensemble des composants logiciels avec trois clients. Le serveur de session live est accessible par tous les clients. Les clients des étudiant·es transmettent et recoivent d'autres informations que les clients des enseignant·es.

Tous les clients ont accès à tous les exercices, stockés dans des repository Git. Le parseur s'exécute sur les clients pour extraire les informations du cours, des compétences et des exercices. Le serveur n'a pas besoin de connaître les détails des exercices, il ne sert que de relai pour les participant·es d'une même session. Le serveur n'est utile que pour participer à des sessions live, PLX peut continuer d'être utilisé sans serveur pour l'entrainement seul·e.

#figure(
  image("../schemas/high-level-arch.png", width:90%),
  caption: [Vue d'ensemble avec le serveur de session live, des clients et notre parseur],
) <high-level-arch>

// Inside == Définition du `Live protocol`
#include "../protocol/protocol.typ"

#pagebreak()

== Vue d'ensemble de l'implémentation

Nous avons implémenté un nouveau module Rust nommé `live` dans la librairie existante de PLX. Cette librairie est prévue pour un usage interne actuellement et n'est pas pensée pour être réutilisée par d'autres projets. Ce module `live` contient plusieurs fichiers pour implémenter le protocole et le serveur.

=== La librairie `plx-core` et son module `live`
Dans la @library-live-arch-deps, l'application desktop et le CLI dépendent de cette librairie `plx-core`. Le CLI contient une sous-commande `plx server` pour démarrer le serveur. L'application desktop dépend du code Rust des modules existants `app`, `core` et `models` qui rendent possible l'entrainement local. Elle dépend aussi de `LiveConfig` pour charger un fichier `live.toml`.

Le fichier `protocol.rs` contient toutes les structures de données autour des messages du protocole: `Session`, `ClientNum`, `ClientRole`, les messages `Action` et `Event` et les types d'erreurs `LiveProtocolError`. Le reste des fichiers implémente les différentes tâches concurrentes gérées par le serveur. Le point d'entrée du serveur est la structure `LiveServer`. Le module `live` dépend aussi de `tokio` pour gérer la concurrence des tâches et `tokio-tungstenite` pour l'implémentation WebSocket.

#figure(
  image("../schemas/library-live-arch-deps.png", width:70%),
  caption: [Aperçu du nouveau module `live` de la librairie `plx-core`],
) <library-live-arch-deps>

PLX est développé avec Tauri @TauriWebsite, framework permettant de créer des applications desktop en Rust. Tauri est une alternative à ElectronJS @ElectronJs et permet de créer une application desktop basé sur une application web. La partie _frontend_ est écrit en VueJS @VuejsWebsite et reste isolée dans une "fenêtre de navigateur", tandis que la partie _backend_ en Rust permet d'accéder aux fichiers et aux commandes systèmes. Tauri permet ainsi de définir des fonctions Rust exposée au _frontend_, appelée commandes Tauri @TauriCommands.


#pagebreak()

=== Les processus en jeu
Sur la @network-arch-ipc-websockets, on voit les différentes communications réseau et processus en jeu. Le binaire `plx-desktop` lance deux processus. Le backend et frontend discutent via le système de communication inter-processus (IPC) de Tauri (qui utilise JSON-RPC @jsonrpcSpec). Les commandes Tauri utilisent notre librairie. Les commandes Tauri sont appelées depuis `commands.ts` et `shared.ts` contient des types communs.

Le serveur PLX peut être déployé dans un conteneur Docker via la commande `plx server`. Le client est implémenté en TypeScript dans `client.ts` et se connecte au serveur.

#figure(
  image("../schemas/network-arch-ipc-websockets.png", width:80%),
  caption: [Aperçu du réseau et processus qui composent le projet PLX],
) <network-arch-ipc-websockets>

=== Typage des commandes Tauri
Pour les commandes Tauri mises à disposition du frontend, l'appel d'une commande se fait par défaut via une fonction `invoke` faiblement typée: le nom de la commande est une _string_ et les paramètres sont mis dans un objet, comme montré sur le @notypescommand. Les types de ces valeurs ne sont pas vérifiés à la compilation, seule l'exécution permet de trouver des erreurs dans la console de la fenêtre du _frontend_. En cas de changement de signature en Rust, nous pourrions oublier d'adapter le code du _frontend_ sans s'en rendre compte.

#text(size: 0.8em)[
#figure(
    grid(columns: 2, rows: 1, align: horizon, column-gutter: 10pt,
  ```rust
#[tauri::command]
pub async fn clone_course(repos: String) -> bool {
    let base = get_base_directory();
    GitRepos::from_clone(&repos, &base).is_ok()
}
```,
```js
import { invoke } from "@tauri-apps/api/core";
const success = await invoke("clone_course", {
    repos: "https://github.com/samuelroland/plx-demo"
});
```)
, caption: [Une commande Tauri en Rust pour cloner le repository d'un cours\ et son appel faiblement typé en TypeScript.]) <notypescommand>
]

Pour résoudre ce problème, le projet `tauri-specta` @TauriSpectaCratesio nous permet de générer une définition une fonction bien typée de l'appel à la commande, après avoir annoté la fonction Rust et les types des paramètres.

#text(size: 0.8em)[
#figure(

  block(width: 32em,
zebraw(
    numbering: false,
    highlight-lines: (1, 7),
    highlight-color: blue.lighten(80%),
      
```rust
#[derive(Serialize, Debug, specta::Type)]
pub struct CourseWithConfig {
    course: Course,
    config: Option<LiveConfig>,
}
#[tauri::command]
#[specta::specta]
pub async fn get_local_courses() -> Vec<CourseWithConfig> {
  // ...
}
```)) , caption: [Exemple d'annotation avec `tauri-specta` sur la commande Tauri et sur les structures associées]) <spectademo>
]

Le @spectademo démontre comment annoter une commande Tauri avec `#[specta::specta]`. Cette commande permet de récupérer les cours PLX locaux et retourne un vecteur de `CourseWithConfig`. Notre structure `CourseWithConfig` et les types utilisés dans ses champs, tels que `Course` et `LiveConfig`, ont également été annotées avec `specta::Type`.

#text(size: 0.8em)[
#figure(
```js
// Commande TypeScript autogénérée par tauri-specta
export const commands = {
  async cloneCourse(repos: string): Promise<boolean> {
    return await invoke("clone_course", { repos });
  }
}
// Exemple d'appel dans Home.vue
const success = await commands.cloneCourse("https://github.com/samuelroland/plx-demo")
```, caption: [Différence d'appel des commandes grâce à `tauri-specta`, par rapport à @notypescommand])
]

Si la commande en Rust changeait de nom, de type des paramètres ou de valeur de retour, maintenant que l'appel est typé, le _frontend_ ne compilera plus et le changement nécessaire en TypeScript ne pourrait pas être oublié. Le fichier généré est `desktop/src/ts/commands.ts`.

=== Partage des types

Les structures de données comme `Action`, `Event`, `LiveProtocolError`, `Session`, `CheckStatus` sont également utiles du côté du client TypeScript. On aimerait éviter de devoir définir des types TypeScript manuellement en doublon des types Rust afin de faciliter le développement et les changements du protocole. Il existe plusieurs solutions pour exporter les types Rust vers des types TypeScript équivalent. Le CLI `typeshare` @1passwordTypeshare a permis d'exporter automatiquement les types communs, en activant l'export via une annotation `#[typeshare]`. Le fichier généré est `desktop/src/ts/shared.ts`.

Prenons un exemple en @checkstatuscode avec le résultat d'un check. L'attribut `#[serde...]` demande que le `CheckStatus` soit sérialisé avec un champ discriminant `type` et son contenu sous un champ `content`. Cette conversion est nécessaire pour permettre de générer un équivalent TypeScript.

// TODO make sure à jour après intégration finale

#text(size: 0.8em)[
#grid(columns: (4fr, 3fr), rows: 1, align: horizon, column-gutter: 10pt,
    [
    #figure(
```rs
#[derive(Serialize, Deserialize, Eq, PartialEq, Clone, Debug)]
#[serde(tag = "type", content = "content")]
#[typeshare]
pub enum CheckStatus {
    Passed,
    CheckFailed(String),
    BuildFailed(String),
    RunFailed(String),
}
#[derive(Serialize, Deserialize, Eq, PartialEq, Clone, Debug)]
#[typeshare]
pub struct ExoCheckResult {
    pub index: u16,
    pub state: CheckStatus,
}
```, caption: [2 types Rust pour décrire le résultat d'un check.]) <checkstatuscode>],
figure(
```js
export type CheckStatus = 
  | { type: "Passed", content?: undefined }
  | { type: "CheckFailed", content: string }
  | { type: "BuildFailed", content: string }
  | { type: "RunFailed", content: string };

export interface ExoCheckResult {
  index: number;
  state: CheckStatus;
}
``` , caption: [Equivalent TypeScript des 2 types. Les types `u16` et `String` ont être pu converti vers `number` et `string`]),

// really named CheckStatus ?
)
]

== Implémentation du client

Le client a été développé dans le _frontend_ de PLX pour simplifier l'implémentation. En effet, une partie des messages pourrait être envoyée depuis la librairie, par exemple dès qu'un résultat de check est disponible. Et une autre partie viendrait de l'interface graphique via les boutons de gestion de sessions. Nous ne pouvons pas avoir deux connexions WebSocket séparées, les messages du _frontend_ devrait donc passer par des commandes Tauri pour arriver sur le socket géré en Rust. Pour les actions de sessions, cela peut fonctionner mais cela devient difficile à gérer lorsqu'il faut attendre des événements comme `ForwardFile` et `ForwardResult` sur le websocket et en même temps de continuer de pouvoir envoyer des actions comme `StopSession`.

Après avoir tenté l'approche précédente, gérer tout le client dans le _frontend_ s'est révelé beaucoup plus simple. Au final, l'entrainement dans une session live ne fait de différence que dans l'interface. Le backend de l'application desktop n'a pas besoin de se préoccuper de savoir si l'exercice est fait seul·e ou dans une session live. A la réception de résultats des checks ou d'erreurs de compilation, le _frontend_ se charge d'envoyer des actions `SendFile` et `SendResult`.

=== Implémentation du tableau de bord
Avant de présenter l'implémentation technique, voici un aperçu du tableau de bord réalisé pour les clients leaders et des changements d'interface pour les clients followers.

#figure(
  image("../imgs/session-creation.png", width: 60%),
  caption: [Création de la session, avec un nom `jack`],
) <fig-session-creation>

#figure(
  image("../imgs/join-session.png", width: 60%),
  caption: [Il est possible de rejoindre la session `jack`, les sessions du cours sont listées],
) <fig-join-session>

todo les stats

todo choix des exos

todo switch d'exos

todo lancement d'un exo étudiant, erreur de build

todo code actuel et erreur de build disponible dans le dashboard


== Implémentation du serveur

=== Lancement

Une fois lancé via la commande `plx server`, si on y connecte un client et qu'on envoie des actions, on peut directement voir sur le @serverlogs des logs pour visualiser les messages reçus et envoyés.
// todo variable d'env pour activer les logs ??
#text(size: 0.8em)[
#figure(
```
> plx server
Started PLX server on port 9120
ClientManager for new client
SERVER: Received from 4cd31b74-0192-4900-8807-70912cc9d5d8: {
  "type": "GetSessions",
  "content": {
    "group_id": "https://github.com/samuelroland/plx-demo"
  }
}
SERVER: Sending to 4cd31b74-0192-4900-8807-70912cc9d5d8: {
  "type": "SessionsList",
  "content": []
}
SERVER: Received from 4cd31b74-0192-4900-8807-70912cc9d5d8: {
  "type": "StartSession",
  "content": {
    "name": "jack",
    "group_id": "https://github.com/samuelroland/plx-demo"
  }
}
SERVER: Sending to 4cd31b74-0192-4900-8807-70912cc9d5d8: {
  "type": "SessionJoined",
  "content": 0
}
```, caption: [Sortie console du serveur à la réception de l'action `GetSessions`,#linebreak()répondu par un `SessionsList`, puis un `StartSession` reçu ce qui génère un `SessionJoined`.]) <serverlogs>
]

=== Gestion de la concurrence
L'exemple précédent ne comportait qu'un seul client, en pratique nous en auront des centaines connectés en même temps, ce qui pose un défi de répartition du travail sur le serveur. En effet, le serveur doit être capable de faire plusieurs choses à la fois, dont une partie des tâches qui sont bloquantes:
+ Réagir à la demande d'arrêt, lors d'un `Ctrl+c`, le serveur doit s'arrêter proprement pour fermer les sessions et envoyer un `Event::ServerStopped`.
+ Attendre de futurs clients qui voudraient ouvrir une connexion TCP
+ Attendre de messages sur le _socket_ pour chaque client
+ Parser le JSON des messages des clients et vérifier que le rôle permet l'action
+ Parcourir la liste des clients d'une session pour leur broadcaster un message l'un après l'autre
+ Envoyer un `Event` pour un client donné
+ Gérer les sessions présentes, permettre de rejoindre ou quitter, de lancer ou d'arrêter ces sessions

Une approche basique serait de lancer un nouveau _thread_ natif (fil d'exécution, géré par l'OS) à chaque nouveau client pour que l'attente sur le socket des messages envoyés puisse se faire sans bloquer les autres. Cette stratégie pose des problèmes à large échelle, car un thread natif possède un coût non négligeable. L'ordonnancement de l'OS, qui décide sur quel coeur du processeur pourra travailler chaque thread et à quel moment, a un certain cout. Si on démarre des centaines de threads natifs, l'ordonnanceur va perdre beaucoup de temps à constamment ordonnancer tous ces threads et les mettre en place.

Une solution à ce problème est de passer vers du Rust `async`. Concrètement, les fonctions asynchrones sont préfixées du mot-clé `async` et des appels de ces fonctions suffixés de `.await`). Grâce au _runtime_ `Tokio`, librairie largement utilisée dans l'écosystème Rust, le code devient asynchrone grâce au lancement de threads virtuels, appelés #quote("tâches Tokio") @TokioTasksDocs. Au lieu d'être soumis à un ordonnancement préemptif de l'ordonnanceur de l'OS, les tâches Tokio ne sont pas préemptées mais redonnent le contrôle au _runtime_ à chaque `.await`. Cette asynchronisme permet d'attendre le résultat du réseau sans bloquer le _thread_ natif sur laquelle est exécutée la tâche. Seul la tâche tokio sera mis dans un fil d'attente géré par le runtime pour être relancée plus tard une fois le résultat arrivé. Le _runtime_ lui même ordonnance ses tâches sur plusieurs _threads_ natifs, pour permettre un parallélisme en plus de la concurrence existante. #footnote([Plus de détails sur les tâches Tokio sont disponibles dans sa documentation @TokioTasksDocs])
// TODO okay ?

Ce runtime de threads virtuelles permet ainsi de lancer des milliers de tâches tokio avec un faible cout mémoire ou du temps nécessaire à leur ordonnancement qui est plus léger. Tokio est donc une solution bien adaptée aux applications en réseau avec de nombreux clients concurrents mais aussi beaucoup d'attente sur des entrées/sorties. @TokioTasksDocs
// TODO check explication tokio

// TODO BCS
// TODO: est-ce que ca doit faire partie de létat de lart plutot cet explication de Tokio et la réflexion sur sync vers async ??

#pagebreak()

=== Tâches tokio

// Sur la @servers-tasks, nous observons 12 clients connectés, les clients 1 à 6 sont connectés dans la session 1. Les clients 7 à 12 dans la session 2. Les clients en orange sont des leaders. Chaque bloc à l'intérieur du serveur, excepté le `SessionsManagement` correspond à une tâche tokio indépendante, avec laquelle la communication se fait par _channel_.
Sur la @servers-tasks, nous observons 5 clients connectés, les clients 1 à 4 sont connectés dans la session 1 et le 5ème n'est pas connecté à une session. Le client en orange est le leader de la session 1. Chaque rectangle à l'intérieur du serveur (sauf le `SessionsManagement`), correspond à une tâche tokio indépendante, avec laquelle la communication se fait uniquement par _channel_ (système de messages aussi appelé _message passing_).

Le point d'entrée est le `LiveServer`. Il attend sur le port 9120 dans l'attente de nouveaux clients qui veulent se connecter en TCP. Il doit ensuite gérer l'initialisation de la connexion WebSocket (_handshake_), qui inclut la vérification du numéro de version et de la présence du `client_id`. Une fois le client connecté avec succès, le `LiveServer` lance un nouveau `ClientManager` dans une tâche Tokio séparée. Cette tâche devient propriétaire de l'instance du WebSocket et reçoit aussi une référence partagée sur le `SessionsManagement`. Le `LiveServer` peut ainsi continuer d'attendre d'autres clients.

Le `SessionsManagement` n'est qu'un état partagé au serveur qui implémente différentes méthodes pour changer cet été. Il est initialisé par le `LiveServer` et accédé par les `ClientManager` et s'occupe de stocker les informations relatives aux sessions en cours.

Le `ClientManager` étant de seul à accéder au socket de son client, il doit s'occuper de recevoir des messages `Action` du client. Il doit aussi transmettre sur le socket les `Event` que le `SessionBroadcaster` lui transfère.

Tous les `ClientManager` ont un _channel_ (flèche violette) vers les `SessionBroadcaster`. Comme leur nom l'indique, ils ne servent qu'à broadcaster un message à tous les leaders ou tous les clients de la session. Leur état stocke la partie transmission du _channel_ vers chaque `ClientManager` de la session (les flèches vertes).

#figure(
  image("../schemas/server-components.png", width:100%),
  caption: [Aperçu des tâches tokio lancées et interactions possibles pour 5 clients et 1 session en cours.],
) <servers-tasks>

Le `ClientManager`, lors de la réception d'un message, doit parser le JSON du message vers la structure `Action`. Une fois le message extrait, il doit vérifier que le rôle permet l'action ou alors renvoyer une erreur directement. Si la demande est autorisée et concerne la gestion de sessions alors il peut l'effectuer en utilisant une des méthodes de `SessionsManagement`, comme `get_sessions()` par exemple. Dans le cas d'un `SendFile`, si le clien est bien dans une session, il peut directement créer le `ForwardFile` et l'envoyer au `SessionBroadcaster` pour qu'il puisse l'envoyer à tous les leaders.

Le `SessionsManagement` possède deux `HashMap` (tables de hachage avec clés/valeurs): la première contient des sessions regroupées par `group_id`. Chaque session contient évidemment le nom et `group_id`, mais également le `client_id` du créateur de la session et le dernier `client_num` attribué. Une seconde liste existe pour lier `client_id` de leader vers la session créée pour facilement retrouver la session dans la première liste.

// TODO besoin de voir les actions effectuées de bout en bout pour un message `SendFile` pour mieux se représenter les interactions ou déjà clair ??

// Tous les types des structures de données du protocole sont définies en Rust. Les messages sont en fait des enumérations `Action` et `Event` en Rust. La version JSON des messages n'est qu'un dérivé d'une liste d'exemples utilisant ces types.

== Tests de bouts en bouts

Les tests de bout en bouts peuvent être lancés dans le repository `plx` de la manière suivante.

#figure(
```
> cargo test --test live

running 16 tests
test websocket_can_connect_with_client_id_and_protocol_version ... ok
test exo_switch_without_session_fails ... ok
test exo_switch_from_leader_is_forwarded_when_session_exists ... ok
test get_sessions_works ... ok
test websocket_fails_to_connect_without_info ... ok
test websocket_fails_with_different_version_number ... ok
test websocket_can_connect_with_client_id_containins_special_chars ... ok
test websocket_fails_with_missing_client_id ... ok
test cannot_create_same_session_twice ... ok
test exo_switch_from_follower_fails ... ok
test can_join_session_and_get_correct_events_back ... ok
test client_can_leave_session_and_leader_can_receive_stats ... ok
test client_cannot_leave_session_when_not_joined ... ok
test get_sessions_correctly_use_group_id ... ok
test forwarding_to_leaders_work ... ok
test session_continues_to_exist_when_leader_disconnects ... ok
``` , caption: [Aperçu des 16 tests développés])

Nous avons d'abord préparé quelques fonctions utilitaires pour lancer un serveur sur un port aléatoire et lancer des clients qui se connectent à ce serveur, comme visible sur le @utilsfns.
#figure(
```rust
/// Spawn a test server on a random dynamic port
fn spawn_test_server() -> u16 {
    let random_dynamic_port = rand::random_range(49152..65535);
    // https://superuser.com/questions/956226/what-are-the-differences-between-the-3-port-types

    thread::spawn(move || {
        let server = LiveServer::new().unwrap();
        server.start(random_dynamic_port, false);
    });
    // just a short sleep so the server has time to start before clients start connecting
    thread::sleep(Duration::from_millis(90));
    random_dynamic_port
}

/// Spawn a server and N connected clients (no session yet)
fn spawn_server_and_n_clients(n: u16) -> Vec<LiveClient> {
    assert!(n > 0);
    let random_port = spawn_test_server();
    let mut clients = Vec::new();
    for i in 0..n {
        let c = LiveClient::connect("127.0.0.1", random_port, format!("SecretId{i}")).unwrap();
        clients.push(c);
    }
    clients
}
```, caption: [Fonctions utilitaires utilisant le `LiveServer` et notre client de test `LiveClient`]) <utilsfns>

Voici ensuite un exemple de test en @testsrv qui vérifie qu'il n'est pas possible de créer deux sessions avec le même nom et `group_id`. Nous lancons un serveur de test avec deux clients connectés. Un premier client crée une session avec les constantes `NAME` et `GROUP_ID`, en envoyant un message `StartSession`. Nous nous assurons que la session est bien créée en attendant le `SessionJoined` en retour. Puis un autre client teste de faire la même action `StartSession` et nous devons recevoir l'erreur `olError::FailedToStartSession` en retour. Ce test passe, notre serveur gère correctement cette unicité des sessions.
#figure(
```rust
#[test]
#[ntest::timeout(4000)]
fn cannot_create_same_session_twice() {
    let c = &mut spawn_server_and_n_clients(2);
    c[0].send_msg(Action::StartSession {
        name: NAME.to_string(),
        group_id: GROUP_ID.to_string(),
    });
    assert_eq!(
        c[0].wait_on_next_event().unwrap(),
        Event::SessionJoined(ClientNum(0))
    );
    c[1].send_msg(Action::StartSession {
        name: NAME.to_string(),
        group_id: GROUP_ID.to_string(),
    });
    assert_eq!(
        c[1].wait_on_next_event().unwrap(),
        Event::Error(LiveProtocolError::FailedToStartSession(
            "There is already a session with the same group id and name combination.".to_string()
        ))
    );
}
```, caption: [Exemple de tests de bout en bout])<testsrv>

