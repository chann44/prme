package templates

import (
	yaml "go.yaml.in/yaml/v4"
) // Or go.yaml.in/yaml/v4

type TemplateConfig map[string]map[string][]struct {
	Name string `yaml:"name"`
	Repo string `yaml:"repo"`
}

func ParseTemplateConfig(data []byte) (TemplateConfig, error) {
	var config TemplateConfig

	err := yaml.Unmarshal(data, &config)
	if err != nil {
		return nil, err
	}

	return config, nil
}
