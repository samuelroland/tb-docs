#context {
  let tables = query(figure.where(kind: image))
  if tables.len() != 0 {
    outline(title: "Tables des figures", target: figure.where(kind: image))
  }
}

#context {
  let tables = query(figure.where(kind: raw))
  if tables.len() != 0 {
    outline(title: "Tables des snippets", target: figure.where(kind: raw))
  }
}

