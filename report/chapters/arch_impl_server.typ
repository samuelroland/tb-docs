= Développement du serveur de session live <arch_impl_server>
Cette partie documente l'architecture et l'implémentation du serveur de session live, ainsi que le client mis en place.

== Implémentation des POC
Les POC ont été implémenté dans le dossier `pocs` du repository Git de la documentation du projet. Ce dossier est accessible depuis un navigateur sur #link("https://github.com/samuelroland/tb-docs/tree/main/pocs")[https://github.com/samuelroland/tb-docs/tree/main/pocs].

// TODO: lien qqepart des 2-3 repos ?

// Inside == Définition du `Live protocol`
#include "../protocol/protocol.typ"

=== Implémentation du serveur

pas d'état plus que dernier code et résultats, pas de persistence.

=== Implémentation du client

#pagebreak()
