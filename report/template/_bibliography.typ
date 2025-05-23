// #bibliography("../bibliography.yaml", style: "ieee")

// todo corriger encore tous les soucis avec cette bibliographie
// TODO: cette bibliographie ne respecte pas encore tous les standards de la HEIG-VD, encore en rôdage avec Typst et le guide de la bibliothèque sur la norme ISO-690...

#set text(size: 0.8em);

// The text language is not supported by Typst at the moment, here is a simple hack that translate the 2 pieces of English to French !
#show "Available from": "Disponible à l'adresse"
#show "Online": "En ligne"
= Bibliographie
*Avertissement: le format de cette bibliographie n'est pas encore tout à fait correct, notamment sur la gestion des auteurs et des contributeurs. Il manque certains nom d'auteurs ou dates de consultation. Cela sera corrigé par la suite avant la rendu final.*
// TODO fix that
#bibliography("../bibliography.yml", style: "iso-690-numeric", title: none)
