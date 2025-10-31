<div align="center">

```
 ██████╗ ██████╗ ███╗   ███╗███████╗
 ██╔══██╗██╔══██╗████╗ ████║██╔════╝
 ██████╔╝██████╔╝██╔████╔██║█████╗  
 ██╔═══╝ ██╔══██╗██║╚██╔╝██║██╔══╝  
 ██║     ██║  ██║██║ ╚═╝ ██║███████╗
 ╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
```

# 🚀 Prme

<div align="center">

![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Go Report Card](https://goreportcard.com/badge/github.com/chann44/prme?style=for-the-badge)](https://goreportcard.com/report/github.com/chann44/prme)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](CONTRIBUTING.md)

**A lightning-fast CLI tool to bootstrap your next project with curated starter templates**

[Features](#-features) •
[Installation](#-installation) •
[Usage](#-usage) •
[Templates](#-available-templates) •
[Contributing](#-contributing)

</div>

---

## 📖 Overview

Prime is an interactive terminal-based project generator that helps developers quickly start new projects with pre-configured templates. Choose your language, select your project type, pick a template, and you're ready to code!

Built with [Bubble Tea](https://github.com/charmbracelet/bubbletea) for a delightful terminal UI experience.

## ✨ Features

- 🎨 **Interactive TUI** - Beautiful terminal interface powered by Bubble Tea
- ⚡ **Fast Setup** - Clone and start coding in seconds
- 🔧 **Multiple Languages** - Support for TypeScript, Python, Go, and more
- 🎯 **Project Types** - Web apps, CLI tools, and other project types
- 📦 **Curated Templates** - Hand-picked starter templates with best practices
- 🛠️ **Extensible** - Easy to add your own custom templates

## 🚀 Installation

### Install from source

Make sure you have [Go 1.21+](https://golang.org/dl/) installed.

```bash
go install github.com/chann44/prme@latest
```

### Build locally

```bash
# Clone the repository
git clone https://github.com/chann44/prme.git
cd prime

# Build the binary
go build -o prime cmd/main.go

# Optional: Move to your PATH
sudo mv prime /usr/local/bin/
```

## 💻 Usage

Simply run the command and follow the interactive prompts:

```bash
prime
```

The CLI will guide you through:

1. **Select a language** - Choose from TypeScript, Python, Go, etc.
2. **Choose project type** - Web app or CLI tool
3. **Pick a template** - Select from available starter templates
4. **Enter project name** - Name your new project
5. **Done!** - Your project is cloned and ready to go

### Example

```bash
$ prime

? Select a language: TypeScript
? Choose project type: web_app
? Select a template: Next.js + Prisma + PostgreSQL
? Enter project name: my-awesome-app

✓ Cloning template...
✓ Project created successfully!

cd my-awesome-app && npm install
```

## 📚 Available Templates

### TypeScript

#### Web Apps
- Next.js + Prisma + PostgreSQL
- Next.js + Prisma + MySQL
- Next.js + Prisma + MongoDB

#### CLI
- TypeScript CLI Starter

### Python

#### Web Apps
- FastAPI + SQLAlchemy + PostgreSQL
- FastAPI + SQLAlchemy + MySQL
- FastAPI + SQLAlchemy + MongoDB

#### CLI
- Python CLI Starter

### Go

#### Web Apps
- Fiber + GORM

#### CLI
- Cobra CLI Starter

## 🔧 Configuration

Templates are defined in `templates/templs.yml`. You can easily add your own templates:

```yaml
your_language:
  web_app:
    - name: Your Template Name
      repo: https://github.com/username/your-template
  cli:
    - name: Your CLI Template
      repo: https://github.com/username/your-cli-template
```

## 🏗️ Project Structure

```
prime/
├── cmd/
│   └── main.go           # Entry point
├── internals/
│   ├── clone.go          # Git cloning logic
│   └── options.go        # Template selection logic
├── templates/
│   ├── template.go       # Template parsing
│   └── templs.yml        # Template definitions
├── ui/
│   ├── modal.go          # UI components
│   └── view.go           # UI views
└── go.mod
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Adding New Templates

To add a new template:

1. Add your template repository to `templates/templs.yml`
2. Ensure the repository is publicly accessible
3. Test the template cloning works correctly
4. Submit a PR with your addition

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - For the amazing TUI framework
- All template maintainers for their excellent starter projects

## 📮 Contact

**Author:** [@chann44](https://github.com/chann44)

**Project Link:** [https://github.com/chann44/prme](https://github.com/chann44/prme)

---

<div align="center">

**If you find this project helpful, please consider giving it a ⭐!**

Made with ❤️ by [chann44](https://github.com/chann44)

</div>

