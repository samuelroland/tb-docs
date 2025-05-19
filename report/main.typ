/*
 Vars
*/
#import "vars.typ": *

#set text(lang: language)

/*
 Includes
*/
#import "template/macros.typ": *

#import "template/style.typ": TBStyle, MyStyle, MyGlobalStyle
#show: TBStyle.with(TBauthor, confidential)
#show: MyGlobalStyle

/*
 Title and template
*/
#import "template/_title.typ": *
#_title(TBtitle, TBsubtitle, TBacademicYears, TBdpt, TBfiliere, TBorient, TBauthor, TBsupervisor, TBindustryContact, TBindustryName, TBindustryAddress, confidential)
#import "template/_second_title.typ": *
#_second_title(TBtitle, TBacademicYears, TBdpt, TBfiliere, TBorient, TBauthor, TBsupervisor, TBindustryName, TBresumePubliable)
#include "template/_preambule.typ"
#import "template/_authentification.typ": *
#_authentification(TBauthor)


#show: MyStyle
/*
 Cahier des charges
*/
#include "chapters/cdc.typ"

/*
 Table of Content
*/
#outline(title: "Table des matières", depth: 3, indent: 15pt)

/*
 Content
*/
#include "chapters/introduction.typ"

#include "chapters/planification.typ"

#include "chapters/etat-de-lart.typ"

//#include "chapters/ch_exemple.typ"

#include "chapters/architecture.typ"

#include "chapters/implementation.typ"

#include "chapters/conclusion.typ"

/*
 Tables
*/

// todo corriger encore tous les soucis avec cette bibliographie
#set text(size: 0.9em);
TODO: cette bibliographie ne respecte pas encore tous les standards de la HEIG-VD, encore en rôdage avec Typst et le guide de la bibliothèque sur la norme ISO-690...

#include "template/_bibliography.typ"
#include "template/_figures.typ"
#include "template/_tables.typ"

/*
 Annexes
*/
#include "chapters/outils.typ"

