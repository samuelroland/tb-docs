/**
 * @file A human-writable data format generator
 * @author Samuel Roland
 * @license All rights reserved
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "dy",

  rules: {
    source_file: ($) => repeat($._line),
    _line: ($) =>
      seq(
        choice($.commented_line, $.prefixed_line, $.list_line, $.content_line),
        "\n",
      ),
    prefixed_line: ($) =>
      seq(
        $.prefix,
        optional(repeat($.property)),
        optional(seq(" ", $.content)),
      ),
    commented_line: (_) => token(seq(/\/\/ /, /.+/)),
    list_line: ($) =>
      seq($.dash, repeat($.property), optional(" "), optional($.content)),
    dash: (_) => token(prec(2, /- /)),
    prefix: (_) => token(prec(1, choice("exo", "sol", "opt"))),
    property: (_) => token(prec(3, seq(".", choice("multiple", "ok")))),
    content_line: ($) => repeat1($.content),
    content: (_) => token(prec(0, /.+/)),
  },
});
