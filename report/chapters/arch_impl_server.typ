= Développement du serveur de session live <arch_impl_server>
Cette partie documente l'architecture et l'implémentation du serveur de session live, l'implémentation d'un client dans PLX et le protocole définit entre les deux.

// Inside == Définition du `Live protocol`
#include "../protocol/protocol.typ"

== Implémentation du serveur

Pour démarrer le serveur, il suffit d'invoquer le CLI `plx server`, qui affichera simplement `Started PLX server on port 9120`. Tout comme le coeur de PLX, le serveur est implémenté uniquement en Rust.

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
```, caption: [Logs de réception du serveur d'actions `GetSessions` et `StartSession`.#linebreak()Renvoi de `SessionsList` d'abord puis de `SessionJoined`.]) <serverlogs>

L'exemple précédent ne comportait qu'un seul client, en pratique nous en auront des centaines connectés en même temps, ce qui pose un défi de gestion des tâches du serveur. En effet, le serveur doit être capable de faire plusieurs choses à la fois, dont une partie des tâches qui sont bloquantes:
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

Ce runtime de threads virtuelles permet ainsi de lancer des milliers de tâches tokio sans se préoccuper de la performance, leur ordonnancement est beaucoup plus léger. Tokio est donc une solution bien adaptée aux applications en réseau avec beaucoup de concurrences mais aussi beaucoup d'attente sur des entrées/sorties.
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

=== Partage des types
Les structures de données du protocole comme `Action`, `Event`, `LiveProtocolError` et d'autres structures utilisées à l'interne de enumérations comme `Session`, `CheckStatus`, ... sont également utiles du côté des clients. Le défi était ainsi d'arriver à exporter ces types Rust vers des types TypeScript équivalent, permettant de faciliter le développement de changements du protocole. La solution n'était pas triviale à mettre en place, mais une combinaison de `tauri-specta` et du CLI `typeshare` a permis d'exporter automatiquement une majorité des types communs.

// todo ref tauri specta et typeshare

Pour les commandes Tauri mises à disposition de l'interface graphique, `tauri-specta` peut générer une définition TypeScript qui simplifie l'appel d'une commande sans utiliser une _string_ non vérifiée à la compilation.
```rust
#[tauri::command]
#[specta::specta]
pub async fn clone_course(repos: String) -> bool {
    let base = get_base_directory();
    GitRepos::from_clone(&repos, &base, Some(1), true).is_ok()
}
```

```ts
export const commands = {
  async cloneCourse(repos: string): Promise<boolean> {
    return await TAURI_INVOKE("clone_course", { repos });
  },
  // ...
}
```

Il devient ainsi très simple d'appeler. Si la méthode Rust change de nom, de type des paramètres ou de valeur de retour, le frontend ne compilera plus et le changement pourra aussi être adapté au _frontend_.
```ts
const success = await commands.cloneCourse("https://github.com/samuelroland/plx-demo")
```
// really named CheckStatus ?

=== Implémentation du tableau de bord
Avant de présenter l'implémentation client, voici un aperçu du tableau de bord réalisé pour les clients leaders et des changements d'interface pour les clients followers.

todo création de session

todo rejoindre la session

todo les stats

todo choix des exos

todo switch d'exos

todo lancement d'un exo étudiant, erreur de build

todo code actuel et erreur de build disponible dans le dashboard

=== Gestion de la connexion
Une structure `LiveClient` est développée comme classe TypeScript.

=== Gestion des messages

#pagebreak()
