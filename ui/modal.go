package ui

import (
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/chann44/prme/internals"
	"github.com/chann44/prme/templates"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
)

type state int

const (
	seleLanguage state = iota
	projectName
	selectAppType
	selectStack
	confirm
	done
)

type modal struct {
	textInput       textinput.Model
	state           state
	languages       []string
	appTypes        []string
	templates       []templates.Starter
	languageCursor  int
	appTypeCursor   int
	stackCursor     int
	selectedLang    string
	selectedAppType string
	selectedStack   string
	quitting        bool
	projectName     string
}

func IntialModal() modal {
	ti := textinput.New()
	ti.Placeholder = "my-awesome-project"
	ti.Focus()
	ti.CharLimit = 156
	ti.Width = 50
	languages := internals.GetLanguages()
	appTypes := internals.GetAppTypes()
	templates, err := internals.GetTemplates(languages[0], appTypes[0])
	if err != nil {
		log.Fatalf("Error getting templates: %v", err)
	}
	return modal{
		textInput:      ti,
		state:          projectName,
		languages:      languages,
		appTypes:       appTypes,
		templates:      templates,
		languageCursor: 0,
		appTypeCursor:  0,
		stackCursor:    0,
	}
}

func (m modal) Init() tea.Cmd {
	return textinput.Blink
}

func (m modal) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmd tea.Cmd

	// Update text input if we're in projectName state
	if m.state == projectName {
		switch msg := msg.(type) {
		case tea.KeyMsg:
			switch msg.String() {
			case "ctrl+c", "esc":
				return m, tea.Quit
			case "enter":
				m.projectName = m.textInput.Value()
				if m.projectName != "" {
					m.state = seleLanguage
				}
				return m, nil
			}
		}
		m.textInput, cmd = m.textInput.Update(msg)
		return m, cmd
	}

	switch ms := msg.(type) {
	case tea.KeyMsg:
		switch ms.String() {
		case "ctrl+c", "q":
			return m, tea.Quit
		case "esc":
			// Handle back navigation
			switch m.state {
			case seleLanguage:
				return m, tea.Quit
			case selectAppType:
				m.state = seleLanguage
				return m, nil
			case selectStack:
				m.state = selectAppType
				return m, nil
			case confirm:
				m.state = selectStack
				return m, nil
			case done:
				return m, tea.Quit
			}
		case "up", "k":
			switch m.state {
			case seleLanguage:
				if m.languageCursor > 0 {
					m.languageCursor--
				}
			case selectAppType:
				if m.appTypeCursor > 0 {
					m.appTypeCursor--
				}
			case selectStack:
				if m.stackCursor > 0 {
					m.stackCursor--
				}
			}
		case "down", "j":
			switch m.state {
			case seleLanguage:
				if m.languageCursor < len(m.languages)-1 {
					m.languageCursor++
				}
			case selectAppType:
				if m.appTypeCursor < len(m.appTypes)-1 {
					m.appTypeCursor++
				}
			case selectStack:
				if m.stackCursor < len(m.templates)-1 {
					m.stackCursor++
				}
			}
		case "enter", " ":
			switch m.state {
			case seleLanguage:
				m.selectedLang = m.languages[m.languageCursor]
				m.state = selectAppType
				m.appTypeCursor = 0 // Reset app type cursor
			case selectAppType:
				m.selectedAppType = m.appTypes[m.appTypeCursor]
				// Fetch templates for the selected language and app type
				templates, err := internals.GetTemplates(m.selectedLang, m.selectedAppType)
				if err != nil {
					log.Printf("Error getting templates: %v", err)
					// If no templates found, stay on app type selection
					return m, nil
				}
				if len(templates) == 0 {
					// No templates available for this combination, stay on app type selection
					return m, nil
				}
				m.templates = templates
				m.stackCursor = 0 // Reset stack cursor for new templates
				m.state = selectStack
			case selectStack:
				m.selectedStack = m.templates[m.stackCursor].Name
				m.state = confirm
			case done:
				cwd, errWd := os.Getwd()
				if errWd != nil {
					log.Fatal(errWd)
					m.quitting = true
					return m, tea.Quit
				}
				// Clean project name and ensure it's just the directory name
				cleanProjectName := strings.TrimSpace(m.projectName)
				cleanProjectName = filepath.Base(cleanProjectName)

				// Create path in current working directory
				projectPath := filepath.Join(cwd, cleanProjectName)

				err := internals.CloneRepo(m.templates[m.stackCursor].Repo, projectPath)
				if err != nil {
					log.Fatal(err)
					m.quitting = true
					return m, tea.Quit
				}
				m.quitting = true
				return m, tea.Quit
			}
		case "y":
			if m.state == confirm {
				m.state = done
			}
		case "n":
			if m.state == confirm {
				// Restart from language selection
				m.state = seleLanguage
				m.languageCursor = 0
				m.appTypeCursor = 0
				m.stackCursor = 0
			}
		}
	}
	return m, nil
}
