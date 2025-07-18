= Développement du serveur de session live <arch_impl_server>
Cette partie documente l'architecture et l'implémentation du serveur de session live, l'implémentation d'un client dans PLX et le protocole définit entre les deux.

La @high-level-arch montre la vue d'ensemble des composants logiciels avec trois clients. Le serveur de session live est accessible par tous les clients. Les clients des étudiant·es transmettent et recoivent d'autres informations que les clients des enseignant·es.

Tous les clients ont accès à tous les exercices, stockés dans des repository Git. Le parseur s'exécute sur les clients pour extraire les informations du cours, des compétences et des exercices. Le serveur n'a pas besoin de connaître les détails des exercices, il ne sert que de relai pour les participant·es d'une même session. Le serveur n'est utile que pour participer à des sessions live, PLX peut continuer d'être utilisé sans serveur pour l'entrainement seul·e.

#figure(
  image("../schemas/high-level-arch.png", width:100%),
  caption: [Vue d'ensemble avec le serveur de session live, des clients, et notre parseur],
) <high-level-arch>

// Inside == Définition du `Live protocol`
#include "../protocol/protocol.typ"

#pagebreak()

== Vue d'ensemble de l'implémentation

Nous avons implémenté un nouveau module Rust nommé `live` dans la librairie existante de PLX. Cette librairie est prévue pour un usage interne actuellement et n'est pas pensée pour être réutilisée par d'autres projets. Ce module `live` contient plusieurs fichiers pour implémenter le protocole et le serveur.

=== La librairie et son module `live`
Dans la @library-live-arch-deps, l'application desktop et le serveur dépendent de cette librairie. L'application desktop dépend du code Rust des modules existants `app`, `core` et `models` qui rendent possible l'entrainement local. Elle dépend aussi de `LiveConfig` pour charger un fichier `live.toml`.

Le fichier `protocol.rs` contient toutes les structures de données autour des messages du protocole: `Session`, `ClientNum`, `ClientRole`, les messages `Action` et `Event` et les types d'erreurs `LiveProtocolError`. Le reste des fichiers implémente les différentes tâches concurrentes gérées par le serveur. Le point d'entrée du serveur est la structure `LiveServer`. Le module `live` dépend aussi de `tokio` pour gérer la concurrence des tâches et `tokio-tungstenite` pour l'implémentation WebSocket.

#figure(
  image("../schemas/library-live-arch-deps.png", width:70%),
  caption: [Aperçu du nouveau module `live` de la librairie],
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

// todo les commandes CLI autour du parseur dans tout ça il va où ?
// todo ref tauri specta et typeshare
=== Typage des commandes Tauri
Pour les commandes Tauri mises à disposition du frontend, l'appel d'une commande se fait via une fonction `invoke` faiblement typée: le nom de la commande est une _string_ et les paramètres sont mis dans un objet, comme montré sur le @notypescommand. Ces valeurs ne sont pas vérifiés à la compilation, seule l'exécution permet de trouver des erreurs dans la console de la fenêtre du _frontend_.

#figure(
  text(size: 0.8em)[
    #grid(columns: 2, rows: 1, align: horizon, column-gutter: 10pt,
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
```)]
, caption: [Une commande Tauri en Rust pour cloner le repository d'un cours\ et son appel faiblement typé en TypeScript.]) <notypescommand>

Le projet `tauri-specta` @TauriSpectaCratesio nous permet de générer une définition une fonction bien typée de l'appel à la commande, après avoir annoté la fonction Rust avec `#[specta::specta]`. Il faut aussi annoter tous les types des paramètres passés.

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

Prenons un exemple avec le résultat d'un check. L'attribut `#[serde...]` demande que le `CheckStatus` soit sérialisé avec un champ discriminant `type` et son contenu sous un champ `content`. Cette conversion est nécessaire pour permettre de générer un équivalent TypeScript.

// TODO should i mention figure x ? for attribute serde

// TODO make sure à jour après intégration finale

#text(size: 0.8em)[
#grid(columns: (auto, 1fr), rows: 1, align: horizon, column-gutter: 10pt,
figure(
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
```, caption: [2 types Rust pour décrire le résultat d'un check.]),
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

// todo ou mettre ca
// TODO utile

== Implémentation du client

// todo schéma architecture globale du client

Le client a été développé dans le _frontend_ de PLX pour simplifier l'implémentation. En effet, une partie des messages pourrait être envoyée depuis la librairie, par exemple dès qu'un résultat de check est disponible. Et une autre partie viendrait de l'interface graphique via les boutons de gestion de sessions. Nous ne pouvons pas avoir deux connexions WebSocket séparées, les messages du _frontend_ devrait donc passer par des commandes Tauri pour arriver sur le socket géré en Rust. Pour les actions de sessions, cela peut fonctionner mais cela devient difficile à gérer lorsqu'il faut attendre des événements comme `ForwardFile` et `ForwardResult` sur le websocket et en même temps de continuer de pouvoir envoyer des actions comme `StopSession`.

Après avoir tenté l'approche précédente, gérer tout le client dans le _frontend_ s'est révelé beaucoup plus simple. Au final, l'entrainement dans une session live ne fait de différence que dans l'interface. Le backend de l'application desktop n'a pas besoin de se préoccuper de savoir si l'exercice est fait seul·e ou dans une session live. A la réception de résultats des checks ou d'erreurs de compilation, le _frontend_ se charge d'envoyer des actions `SendFile` et `SendResult`.

=== Implémentation du tableau de bord
Avant de présenter l'implémentation technique, voici un aperçu du tableau de bord réalisé pour les clients leaders et des changements d'interface pour les clients followers.

*Screenshots à venir, quand l'interface aura été un poil amélioré et que le switch d'exo fonctionnera*.

todo création de session

todo rejoindre la session

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
+ Attendre de futur clients qui voudraient ouvrir une connexion TCP
+ Attendre de messages sur le websocket pour chaque client
+ Parser le JSON des messages des clients et vérifier que le rôle permet l'action
+ Parcourir la liste des clients d'une session pour leur broadcaster un message l'un après l'autre
+ Envoyer un `Event` pour un client donné
+ Gérer les sessions présentes, permettre de rejoindre ou quitter, de lancer ou d'arrêter ces sessions

Une approche basique serait de lancer un nouveau _thread_ natif (fil d'exécution, géré par l'OS) à chaque nouveau client pour que l'attente sur le socket des messages envoyés puisse se faire sans bloquer les autres. Cette stratégie pose des problèmes à large échelle, car un thread natif possède un coût non négligeable. L'ordonnancement de l'OS, qui décide sur quel coeur du processeur pourra travailler chaque thread et à quel moment, a un certain cout. Si on démarre des centaines de threads natifs, l'ordonnanceur va perdre beaucoup de temps à constammer ordonnancer tous ces thread et les mettre en place.

Une solution à ce problème, est de passer vers du Rust `async`. Concrètement, il suffit d'avoir des fonctions préfixées du mots clé `async` et des appels de ces fonctions suffixés de `.await`). Grâce au _runtime_ `Tokio`, librairie largement utilisée dans l'écosystème Rust, le code devient asynchrone grâce au lancement de threads virtuelles, appelée des tâches Tokio. Au lieu d'être soumis à un ordonnancement préemptif de l'ordonnanceur de l'OS, les tâches Tokio ne sont pas préemptées mais redonnent le contrôle au runtime à chaque `.await`. Ainsi, dès qu'une fonction qui intéragit avec le réseau en lecture ou écriture, elle sera asynchrone, après l'avoir lancé l'usage de `.await` permettra d'attendre son résultat sans bloquer le thread natif sous jacent. Seul la tâche tokio sera mis dans un fil d'attente géré par le runtime pour être relancée plus tard une fois un résultat arrivé. Le runtime lui même exécute ses tâches sur plusieurs _threads_ natifs, pour permettre un parallélisme en plus de la concurrence possible sur un _thread_.
// TODO okay ?

Ce runtime de threads virtuelles permet ainsi de lancer des milliers de tâches tokio sans que cela pose soucis au niveau du coût mémoire ou du temps dédié à leur ordonnancement qui est plus léger. Tokio est donc une solution bien adaptée aux applications en réseau avec de nombreux clients concurrents mais aussi beaucoup d'attente sur des entrées/sorties.
// TODO check explication tokio

TODO: est-ce que ca doit faire partie de létat de lart plutot cet explication de Tokio et la réflexion sur sync vers async ??

#pagebreak()

=== Tâches tokio

Sur la @servers-tasks, nous observons 12 clients connectés, les clients 1 à 6 sont connectés dans la session 1. Les clients 7 à 12 dans la session 2. Les clients en orange sont des leaders. Chaque bloc à l'intérieur du serveur, excepté le `SessionsManager` correspond à une tâche tokio indépendante, avec laquelle la communication se fait par _channel_.

Le point d'entrée est le `LiveServer`, qui attend sur le port 9120, et qui doit accepter les nouveaux clients qui veulenet se connecter, et faire le _handshake_ WebSocket ensuite. La vérification du numéro de version et de la présence du `client_id` sont faite à ce moment. Une fois le client connecté avec succès, un nouveau `ClientManager` est lancé dans une tâche Tokio séparée, avec l'instance du WebSocket et une référence sur le `SessionsManager`.

Le `ClientManager` étant de seul à accéder au WebSocket de son client, il doit s'occuper de recevoir des `Action`, parser le JSON, vérifier que le rôle permet l'action ou renvoyer une erreur, et lancer les actions demandées. Il doit aussi transmettre les `Event` que le `SessionBroadcaster` lui transfère.

Tous les `ClientManager` ont un channel (flèche violette) vers les `SessionBroadcaster`. Comme leur nom l'indique, il ne serve qu'à broadcaster un message à tous les leaders ou tous les clients de la session. Leur état stocke la partie transmission de _channel_ vers chaque `ClientManager` de la session.

Le `SessionsManager` quand a lui est le coordinateur de la gestion des sessions. Il maintiant la liste des sessions en cours, organisés par `group_id`.

// TODO def channel ?

#figure(
  image("../schemas/server-components.png", width:100%),
  caption: [Aperçu des tâches tokio lancées pour 12 clients et 2 sessions en cours.],
) <servers-tasks>


// La crate `tokio-tungstenite` nous fournit une adaption de `tungstenite`, pour fonctionner avec Tokio.

// Tous les types des structures de données du protocole sont définies en Rust. Les messages sont en fait des enumérations `Action` et `Event` en Rust. La version JSON des messages n'est qu'un dérivé d'une liste d'exemples utilisant ces types.

// pas d'état plus que dernier code et résultats, pas de persistence.

// pas de support pour plusieurs leaders

#pagebreak()
