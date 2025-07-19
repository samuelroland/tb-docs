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

  // Insert non breakable space before any : in any paragraph (this doesn't include code snippets)
  // show par: it => [
  // #show ":": sym.space.nobreak + ":"
  //   #it
  // ]
  // # TODO fix this and enable again, it it included in inline #raw ...
  // https://github.com/typst/typst/issues/3848
  // todo include headings, list and others ??

  // Lora font released under OFL 1.1
  // to install https://www.fontsquirrel.com/fonts/lora
  set text(font: "Lora")
  show raw: text.with(size: 0.95em, font: "Fira Code")
  body
}

// My additionnal styling starting at etat de l'art
// A box with a rounded border of light gray
#let roundedbox(body) = {
    box(
      inset: 10pt,
      outset: (y: 0pt),
      radius: 2pt,
      stroke: 1pt + luma(200),
    )[#body]
}

#let MyStyle(body) = {

  // Configure figures supplement color
  let figure_supplement_color = blue

  // If the figure contains a #raw snippet (a code block), we use "Snippet" instead of "Figure" as the supplement
  // todo extend that to image in SVG, considered as snippet also
  show figure.where(kind: raw): set figure(
    supplement: "Snippet"
  )

// Show the figure caption (the text below) with the correct supplement ("Figure" or "Snippet")
// Replace "Fig." by "Figure"
// Remove the dot after the supplement and after the number
// Some a small space above the caption
  show figure.caption: c => context [
    #v(0.1cm)
    #text(fill: figure_supplement_color)[
      #c.supplement.text.replace("Fig.", "Figure") #c.counter.display(c.numbering)
    ]#c.separator.text.replace(".", "") #c.body
  ]

  // Help from https://github.com/typst/typst/discussions/3871
  // Show the reference to a label with the name of the supplement of this reference
  // It's sadly not possible to to add the figure_supplement_color to both the supplement and the number
  set ref(supplement: it => {
    if it.func() == figure {
      if type(it.body) == content {
        text(it.supplement.text.replace("Fig.", "Figure"))
      }
    }
  })

  // Justify the text
  set par(justify: true)
  // Don't justify text in tables
  show table: set par(justify: false)

  show link: underline

  show image: it => {
    if str.ends-with(it.source, "svg") {
      // Hacky exception for syntax SVG where we need to put a bit more padding at the bottom and remove the big inset
      if it.source.contains("specs/") {
        it
      } else if it.source.contains("syntax/") {
        box(
          inset: (bottom: 7pt, x: 4pt),
          outset: (bottom: 0pt),
          radius: 2pt,
          stroke: 1pt + luma(200),
        )[#it]
      } else {
          roundedbox(it)
      }
    } else {
      it
    }
  }

  // Enable syntastica only if the build mode is "full" as it is slow
  let syntastica-enabled = read("../build.mode.txt") == "full"
  show raw: it => if syntastica-enabled { align(left)[#syntastica(it, theme: "catppuccin::latte")]} else { it }

  // Display inline code in a small box with light gray backround that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Show the text of a footnote a bit smaller
  show footnote.entry: set text(size: 0.8em)

  // Display block code in a larger block with more padding
  // include a rounded border around it
  // Add `fill` attribute to define background color
  show raw.where(block: true): block.with(
    inset: 10pt,
    radius: 2pt,
    stroke: 1pt + luma(200)
  )

  body
}
