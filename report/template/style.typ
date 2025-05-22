#import "macros.typ": *
#import "@local/syntastica:0.1.1": syntastica, languages, themes, theme-bg, theme-fg

#let TBStyle(TBauthor, confidential, body) = {
  set heading(numbering: none)

  // Move all 1 level headings to new odd page
  show heading.where(
    level: 1
  ): it => [
    #pagebreak(weak: true)
    // #pagebreak(weak: true, to: "odd")
    #v(2.5em)
    #it
    \
  ]

  // TODO find a way to apply this only to the main outline not the figures and the tables one
  show outline.entry.where(
    level: 1
  ): it => {
    if it.element.func() != heading {
      // Keep default style if not a heading.
      return it
    }
    
    v(20pt, weak: true)
    strong(it)
  }

  let confidentialText = [
    #if confidential{
      [*Confidentiel*]
    }
  ]

  // Set global page layout
  set page(
    paper: "a4",
    numbering: "1",
    header: context{
      columns(2, [
        #align(left)[#smallcaps([#currentH()])]
        #colbreak()
        #align(right)[#TBauthor]
      ])
      hr()
    },
    footer: context{
      if not isfirsttwopages(page){
        hr()
        if isevenpage(page){
          align(left)[#counter(page).display()]
        } else {
          align(right)[#counter(page).display()]
        }
      }
    },
    margin: (
      top: 50pt,
      bottom: 50pt,
      left: 50pt,
      right: 50pt,
      x: 1in
    )
  )

  // LaTeX look and feel :)
  // show raw: set text(font: "New Computer Modern Mono")
  show heading: set block(above: 1.4em, below: 1em)
  
  show heading.where(level:1): set text(size: 25pt)

  show link: underline


  body
}

// My global style
#let MyGlobalStyle(body) = {

  // Lora font released under OFL 1.1
  // to install https://www.fontsquirrel.com/fonts/lora
  set text(font: "Lora")
  show raw: text.with(size: 0.95em, font: "Fira Code")
  body
}

// My additionnal styling starting at etat de l'art
#let MyStyle(body) = {

  // Use "Snippet" instead of Liste -> Snippet 1, Snippet 2, ...
  show figure.where(kind: raw): set figure(
    supplement: "Snippet"
  )
  // todo extend that to image in SVG, considered as snippet also

  set par(justify: true)
  show link: underline

  show image: it => {
    if str.ends-with(it.source, "svg") {
      box(
        inset: 10pt,
        outset: (y: 3pt),
        radius: 2pt,
        stroke: 1pt + luma(200),
        it
      )
    } else {
      it
    }
  }

  // Disable syntastica as it is slow
  let syntastica-enabled = true
  show raw: it => if syntastica-enabled { align(left)[#syntastica(it, theme: "catppuccin::latte")]} else { it }

  // Display inline code in a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )


  // Display block code in a larger block with more padding.
  show raw.where(block: true): block.with(
    // fill: rgb(249, 251, 254),
    inset: 10pt,
    radius: 2pt,
    stroke: 1pt + luma(200)
  )
  body
}
