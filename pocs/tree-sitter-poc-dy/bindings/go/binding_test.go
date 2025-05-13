package tree_sitter_dy_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_dy "github.com/tree-sitter/tree-sitter-dy/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_dy.Language())
	if language == nil {
		t.Errorf("Error loading DY grammar")
	}
}
