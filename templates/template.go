package templates

import (
	"fmt"
	"os"

	yaml "go.yaml.in/yaml/v4"
) // Or go.yaml.in/yaml/v4

type Starter struct {
	Name string `yaml:"name"`
	Repo string `yaml:"repo"`
}

type Language struct {
	WebApp []Starter `yaml:"web_app"`
	CLI    []Starter `yaml:"cli"`
}

type TemplateConfig struct {
	Languages map[string]Language `yaml:",inline"`
}

func ParseTemplateConfig() (TemplateConfig, error) {
	data := readTemplatesFile()
	var config TemplateConfig

	err := yaml.Unmarshal(data, &config)
	if err != nil {
		return TemplateConfig{}, err
	}

	return config, nil
}

func readTemplatesFile() []byte {
	templateFilePath := "templates/templs.yml"
	templateData, err := os.ReadFile(templateFilePath)
	if err != nil {
		fmt.Printf("Error reading template file: %v", err)
		os.Exit(1)
	}
	return templateData
}
