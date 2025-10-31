package main

import (
	"fmt"
	"os"

	"github.com/chann44/prme/ui"
	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	p := tea.NewProgram(ui.IntialModal())
	// templateFilePath := "templates/templs.yml"
	// templateData, err := os.ReadFile(templateFilePath)
	// if err != nil {
	// 	fmt.Printf("Error reading template file: %v", err)
	// 	os.Exit(1)
	// }
	// config, err := templates.ParseTemplateConfig(templateData)
	// if err != nil {
	// 	fmt.Printf("Error parsing template config: %v", err)
	// 	os.Exit(1)
	// }
	//
	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v", err)
		os.Exit(1)
	}
}
