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
// TODO renable this at the end
#import "template/_second_title.typ": *
#_second_title(TBtitle, TBacademicYears, TBdpt, TBfiliere, TBorient, TBauthor, TBsupervisor, TBindustryName, TBresumePubliable)
#include "template/_preambule.typ"

#include "chapters/remerciements.typ"

#import "template/_authentification.typ": *
#_authentification(TBauthor)


#show: MyStyle

// Set numbering for content
#set heading(numbering: "1.1")

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

#include "chapters/arch_impl_server.typ"

#include "chapters/arch_impl_syntax.typ"

#include "chapters/conclusion.typ"

// Remove numbering after content
#set heading(numbering: none)

/*
 Tables
*/

#include "template/_bibliography.typ"
#include "template/_figures.typ"
#include "template/_tables.typ"

/*
 Annexes
*/
= Annexes
#include "chapters/outils.typ"
#pagebreak()
#include "chapters/cdc.typ" // CDC original

