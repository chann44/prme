package main

import (
	"fmt"
	"os"

	"github.com/chann44/prme/ui"
	tea "github.com/charmbracelet/bubbletea"
)

var version = "dev"

func main() {
	if len(os.Args) > 1 && (os.Args[1] == "--version" || os.Args[1] == "-v") {
		fmt.Printf("prime version %s\n", version)
		os.Exit(0)
	}

	p := tea.NewProgram(ui.IntialModal())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v", err)
		os.Exit(1)
	}
}
