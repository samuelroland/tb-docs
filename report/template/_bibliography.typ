// #bibliography("../bibliography.yaml", style: "ieee")

#set text(size: 0.8em);

// The text language is not supported by Typst at the moment, here is a simple hack that translate the 2 pieces of English to French !
#show "Available from": "Disponible à l'adresse"
#show "Online": "En ligne"
= Bibliographie
#bibliography("../bibliography.yml", style: "iso-690-numeric", title: none)
