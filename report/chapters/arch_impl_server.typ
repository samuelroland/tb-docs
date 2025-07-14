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

== Implémentation du serveur

=== Lancement
Pour démarrer le serveur, il suffit d'invoquer le CLI `plx server`, qui affichera `Started PLX server on port 9120` en attente de connexions. Tout comme le coeur de PLX, le serveur est implémenté uniquement en Rust.

Si on lance un client et qu'on envoie des actions, on peut directement voir sur le @serverlogs des logs pour visualiser les messages reçus et envoyés.
// todo variable d'env pour activer les logs ??
#figure(
```
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

Une solution à ce problème, est de passer vers du Rust `async`. Concrètement, il suffit d'avoir des fonctions préfixées du mots clé `async` et des appels de ces fonctions suffixés de `.await`). Grâce au _runtime_ `Tokio`, librairie largement utilisée dans l'écosystème Rust, le code devient asynchrone grâce au lancement de threads virtuelles, appelée des tâches Tokio. Au lieu d'être soumis à un ordonnancement préemptif de l'ordonnanceur de l'OS, les tâches Tokio ne sont pas préemptées mais redonnent le contrôle au runtime à chaque `.await`. Ainsi, dès qu'une fonction qui intéragit avec le réseau en lecture ou écriture, elle sera asynchrone, après l'avoir lancé l'usage de `.await` permettra d'attendre son résultat sans bloquer le thread natif sous jacent. Seul la tâche tokio sera mis dans un fil d'attente géré par le runtime pour être relancée plus tard une fois un résultat arrivé.

Le runtime lui même exécute ses tâches sur plusieurs _threads_ natifs, pour permettre un parallélisme en plus de la concurrence possible sur un _thread_.
// TODO okay ?

Ce runtime de threads virtuelles permet ainsi de lancer des milliers de tâches tokio sans que cela pose soucis au niveau du coût mémoire ou du temps dédié à leur ordonnancement qui est plus léger. Tokio est donc une solution bien adaptée aux applications en réseau avec de nombreux clients concurrents mais aussi beaucoup d'attente sur des entrées/sorties.
// TODO check explication tokio

La crate `tokio-tungstenite` nous fournit une adaption de `tungstenite`, pour fonctionner avec Tokio.

Tous les types des structures de données du protocole sont définies en Rust. Les messages sont en fait des enumérations `Action` et `Event` en Rust. La version JSON des messages n'est qu'un dérivé d'une liste d'exemples utilisant ces types.

Le serveur peut via la structure `LiveServer`

pas d'état plus que dernier code et résultats, pas de persistence.

pas de support pour plusieurs leaders

== Implémentation du client

PLX étant une application _desktop_ développée avec Tauri, une partie est développée en Rust, dont la librairie

// todo schéma architecture globale du client

// todo ref tauri !

Le client a été développé dans l'interface graphique de PLX, pour éviter d'avoir une partie des messages qui viennent du coeur Rust et une autre partie qui viennent de l'interface graphique. L'accès au session live est une sorte d'extension gérée uniquement coté de l'interface graphique. A la réception de résultats des checks ou d'erreurs de compilation, soit elle ne fait que l'affichage.

todo abckend + frontend def

=== Implémentation du tableau de bord
Avant de présenter l'implémentation technique, voici un aperçu du tableau de bord réalisé pour les clients leaders et des changements d'interface pour les clients followers.

todo création de session

todo rejoindre la session

todo les stats

todo choix des exos

todo switch d'exos

todo lancement d'un exo étudiant, erreur de build

todo code actuel et erreur de build disponible dans le dashboard

=== Partage des types
Les structures de données du protocole comme `Action`, `Event`, `LiveProtocolError` et d'autres structures utilisées à l'interne de enumérations comme `Session`, `CheckStatus`, ... sont également utiles du côté des clients. Le défi était ainsi d'arriver à exporter ces types Rust vers des types TypeScript équivalent, permettant de faciliter le développement de changements du protocole. La solution n'était pas triviale à mettre en place. Le CLI `typeshare` @1passwordTypeshare a permis d'exporter automatiquement une majorité des types communs, demandant simplement d'annoter chaque structure commune avec `#[typeshare]`.

Prenons un exemple avec le résultat d'un check, sur le @rusttypes. L'attribut `#[serde...]` demande que le `CheckStatus` soit sérialisé avec un champ discriminant `type` et son contenu sous un champ `content`. Cette conversion est nécessaire pour permettre de générer un équivalent TypeScript.

// TODO make sure à jour après intégration finale

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
```, caption: [2 types Rust pour décrire le résultat d'un check.]) <rusttypes>

#figure(
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
``` , caption: [Equivalent TypeScript des 2 types. Les types `u16` et `String` ont être pu converti vers `number` et `string`]);

// really named CheckStatus ?

// todo ref tauri specta et typeshare

Pour les commandes Tauri mises à disposition de l'interface graphique, il restait aussi le problème de l'appel d'une commande avec son nom sous forme de _string_ et de paramètres, qui ne pouvaient pas être vérifiés à la compilation.

#figure(
  [ ```rust
#[tauri::command]
pub async fn clone_course(repos: String) -> bool {
    let base = get_base_directory();
    GitRepos::from_clone(&repos, &base, Some(1), true).is_ok()
}
```
```js
import { invoke } from "@tauri-apps/api/core";
const success = await invoke("clone_course", {
    repos: "https://github.com/samuelroland/plx-demo"
});
```
], caption: [Une commande Tauri en Rust pour cloner le repository d'un cours et son appel non typé en JavaScript.])

Pour résoudre ce deuxième défi, un autre outil du nom de `tauri-specta` @TauriSpectaCratesio a permis de générer une définition TypeScript de l'appel à la commande, en annotant la fonction Rust avec `#[specta::specta]`.

#figure(
```js
export const commands = {
  async cloneCourse(repos: string): Promise<boolean> {
    return await TAURI_INVOKE("clone_course", { repos });
  }
} ```, caption: [Version TypeScript autogénérée de l'appel à `clone_course`])

Si la méthode Rust changeait de nom, de type des paramètres ou de valeur de retour, au départ, nous risquerions d'oublier de mettre à jour ces appels. Maintenant que l'appel est typé, le _frontend_ ne compilera plus et le changement nécessaire ne pourra pas être oublié.
#figure(
```js
const success = await commands.cloneCourse("https://github.com/samuelroland/plx-demo")
``` , caption: [Appel final facilité et typé])

=== Gestion de la connexion
Une structure `LiveClient` est développée comme classe TypeScript.

=== Gestion des messages



// todo ou mettre ca
L'implémentation de la structure de messages est défini en Rust (enumération `Action` et `Event` dans `src/live/protocol.rs`) et également dans les types commun TypeScript (`desktop/src/ts/shared.ts`) générés.
// TODO utile

#pagebreak()
