// #bibliography("../bibliography.yaml", style: "ieee")

// todo corriger encore tous les soucis avec cette bibliographie
// TODO: cette bibliographie ne respecte pas encore tous les standards de la HEIG-VD, encore en rôdage avec Typst et le guide de la bibliothèque sur la norme ISO-690...

#set text(size: 0.9em);

// The text language is not supported by Typst at the moment, here is a simple hack that translate the 2 pieces of English to French !
#show "Available from": "Disponible à l'adresse"
#show "Online": "En ligne"
#bibliography("../bibliography.yml", style: "iso-690-numeric")
