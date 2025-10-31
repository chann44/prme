package ui

import (
	"log"

	"github.com/chann44/prme/internals"
	"github.com/chann44/prme/templates"
	tea "github.com/charmbracelet/bubbletea"
)

type state int

const (
	seleLanguage state = iota
	selectAppType
	selectStack
	confirm
	done
)

type modal struct {
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
}

func IntialModal() modal {
	languages := internals.GetLanguages()
	appTypes := internals.GetAppTypes()
	templates, err := internals.GetTemplates(languages[0], appTypes[0])
	if err != nil {
		log.Fatalf("Error getting templates: %v", err)
	}
	return modal{
		state:          seleLanguage,
		languages:      languages,
		appTypes:       appTypes,
		templates:      templates,
		languageCursor: 0,
		appTypeCursor:  0,
		stackCursor:    0,
	}
}

func (m modal) Init() tea.Cmd {
	return nil
}

func (m modal) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch ms := msg.(type) {
	case tea.KeyMsg:
		switch ms.String() {
		case "ctrl+c", "esc":
			return m, tea.Quit
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
			case selectAppType:
				m.selectedAppType = m.appTypes[m.appTypeCursor]
				m.state = selectStack
			case selectStack:
				m.selectedStack = m.templates[m.stackCursor].Name
				m.state = confirm
			case confirm:
				m.state = done
				// Call your function here with all selections
			case done:
				m.quitting = true
				return m, tea.Quit
			}
		}
	}
	return m, nil
}
