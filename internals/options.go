package internals

import (
	"fmt"
	"os"
	"sort"

	"github.com/chann44/prme/templates"
)

func GetLanguages() []string {
	cfg, err := templates.ParseTemplateConfig()
	if err != nil {
		fmt.Printf("Error parsing template config: %v", err)
		os.Exit(1)
	}
	langs := make([]string, 0, len(cfg.Languages))
	for lang := range cfg.Languages {
		langs = append(langs, lang)
	}
	sort.Strings(langs)
	return langs

}

func GetAppTypes() []string {
	return []string{"web_app", "cli", "backend", "mobile", "browser_extension", "static", "config"}
}

func GetTemplates(lang string, appType string) ([]templates.Starter, error) {
	cfg, err := templates.ParseTemplateConfig()
	if err != nil {
		return nil, fmt.Errorf("error parsing template config: %w", err)
	}

	langConfig, exists := cfg.Languages[lang]
	if !exists {
		return nil, fmt.Errorf("language '%s' not found", lang)
	}

	// Return templates based on app type
	switch appType {
	case "web_app":
		return langConfig.WebApp, nil
	case "cli":
		return langConfig.CLI, nil
	case "backend":
		return langConfig.Backend, nil
	case "mobile":
		return langConfig.Mobile, nil
	case "browser_extension":
		return langConfig.BrowserExtension, nil
	case "static":
		return langConfig.Static, nil
	case "config":
		return langConfig.Config, nil
	default:
		return nil, fmt.Errorf("app type '%s' not found", appType)
	}
}
