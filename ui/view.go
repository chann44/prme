package ui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("#FF06B7")).
			Background(lipgloss.Color("#1a1a1a")).
			Padding(0, 1).
			MarginBottom(1)

	selectedStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FAFAFA")).
			Background(lipgloss.Color("#7D56F4")).
			Bold(true).
			Padding(0, 1)

	normalStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#AAAAAA")).
			Padding(0, 1)

	highlightStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FFFFFF")).
			Background(lipgloss.Color("#3C3C3C")).
			Padding(0, 1)

	helpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#626262")).
			MarginTop(1)

	resultStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#04B575")).
			Bold(true).
			Padding(1).
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("#04B575"))

	summaryStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#AAAAAA")).
			MarginTop(0).
			MarginBottom(1)
)

func (m modal) View() string {
	if m.quitting {
		return ""
	}

	var s strings.Builder

	switch m.state {
	case projectName:
		s.WriteString(titleStyle.Render("📝 Enter Project Name"))
		s.WriteString("\n\n")
		s.WriteString(m.textInput.View())
		s.WriteString("\n\n")
		s.WriteString(helpStyle.Render("enter: continue • esc: quit"))
	case seleLanguage:
		s.WriteString(titleStyle.Render("🚀 Select a Programming Language"))
		s.WriteString("\n\n")
		for i, lang := range m.languages {
			cursor := " "
			if i == m.languageCursor {
				cursor = "▸"
				s.WriteString(cursor + " " + highlightStyle.Render(lang) + "\n")
			} else {
				s.WriteString(cursor + " " + normalStyle.Render(lang) + "\n")
			}
		}

		s.WriteString("\n")
		s.WriteString(helpStyle.Render("↑/↓: navigate • enter: select • q: quit"))

	case selectAppType:
		s.WriteString(titleStyle.Render("📱 Select Application Type"))
		s.WriteString("\n")
		s.WriteString(summaryStyle.Render(fmt.Sprintf("Language: %s", selectedStyle.Render(m.selectedLang))))
		s.WriteString("\n\n")

		for i, appType := range m.appTypes {
			cursor := " "
			if i == m.appTypeCursor {
				cursor = "▸"
				s.WriteString(cursor + " " + highlightStyle.Render(appType) + "\n")
			} else {
				s.WriteString(cursor + " " + normalStyle.Render(appType) + "\n")
			}
		}

		s.WriteString("\n")
		s.WriteString(helpStyle.Render("↑/↓: navigate • enter: select • esc: back • q: quit"))

	case selectStack:
		s.WriteString(titleStyle.Render("🎨 Select Stack Type"))
		s.WriteString("\n")
		s.WriteString(summaryStyle.Render(fmt.Sprintf("Language: %s | App Type: %s",
			selectedStyle.Render(m.selectedLang),
			selectedStyle.Render(m.selectedAppType))))
		s.WriteString("\n\n")

		for i, stack := range m.templates {
			cursor := " "
			if i == m.stackCursor {
				cursor = "▸"
				s.WriteString(cursor + " " + highlightStyle.Render(stack.Name) + "\n")
				// Show description for the currently highlighted template
				if stack.Description != "" {
					descStyle := lipgloss.NewStyle().
						Foreground(lipgloss.Color("#888888")).
						Italic(true).
						Padding(0, 0, 0, 3).
						Width(80)
					s.WriteString(descStyle.Render("  "+stack.Description) + "\n")
				}
			} else {
				s.WriteString(cursor + " " + normalStyle.Render(stack.Name) + "\n")
			}
		}

		s.WriteString("\n")
		s.WriteString(helpStyle.Render("↑/↓: navigate • enter: select • esc: back • q: quit"))

	case confirm:
		s.WriteString(titleStyle.Render("✓ Confirm Your Selections"))
		s.WriteString("\n\n")

		confirmBox := lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("#7D56F4")).
			Padding(1, 2).
			Width(50)

		confirmText := fmt.Sprintf(`Language:  %s
App Type:  %s
Stack:     %s

Do you want to proceed with these selections?`,
			lipgloss.NewStyle().Foreground(lipgloss.Color("#04B575")).Render(m.selectedLang),
			lipgloss.NewStyle().Foreground(lipgloss.Color("#04B575")).Render(m.selectedAppType),
			lipgloss.NewStyle().Foreground(lipgloss.Color("#04B575")).Render(m.selectedStack))

		s.WriteString(confirmBox.Render(confirmText))
		s.WriteString("\n\n")
		s.WriteString(helpStyle.Render("y: yes • n: restart • esc: back • q: quit"))

	case done:
		result := fmt.Sprintf(`
✓ Configuration Complete!

Language:  %s
App Type:  %s
Stack:     %s

Your selections have been processed successfully!
`, m.selectedLang, m.selectedAppType, m.selectedStack)

		s.WriteString(resultStyle.Render(result))
		s.WriteString("\n\n")
		s.WriteString(helpStyle.Render("Press enter or q to exit"))
	}

	return s.String()
}
