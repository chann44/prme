package internals

import (
	"os"
	"os/exec"
)

func CloneRepo(repoURL, dest string) error {
	cmd := exec.Command("git", "clone", repoURL, dest)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
