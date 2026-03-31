package install

import (
	"embed"
	"fmt"
	"os"
	"path/filepath"
)

//go:embed scripts/*.sh
var scriptFS embed.FS

func materializeScript(scriptName string) (string, func(), error) {
	content, err := scriptFS.ReadFile("scripts/" + scriptName)
	if err != nil {
		return "", nil, fmt.Errorf("未找到内置安装脚本 %s", scriptName)
	}

	tempDir, err := os.MkdirTemp("", "mscript-install-*")
	if err != nil {
		return "", nil, err
	}

	scriptPath := filepath.Join(tempDir, scriptName)
	if err := os.WriteFile(scriptPath, content, 0700); err != nil {
		os.RemoveAll(tempDir)
		return "", nil, err
	}

	cleanup := func() {
		os.RemoveAll(tempDir)
	}

	return scriptPath, cleanup, nil
}
