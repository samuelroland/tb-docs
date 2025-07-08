= Développement du serveur de session live <arch_impl_server>
Cette partie documente l'architecture et l'implémentation du serveur de session live, l'implémentation d'un client dans PLX et que le protocole définit entre les deux.

// Inside == Définition du `Live protocol`
#include "../protocol/protocol.typ"

=== Implémentation du serveur

pas d'état plus que dernier code et résultats, pas de persistence.

pas de support pour plusieurs leaders

=== Implémentation du client

#pagebreak()
