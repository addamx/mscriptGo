package install

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"

	"mscript/internal/ui"
)

type Item struct {
	Label       string
	Description string
	ScriptName  string
}

var installItems = []Item{
	{
		Label:       "common",
		Description: "安装 zip、gemini-cli、@openai/codex",
		ScriptName:  "common.sh",
	},
	{
		Label:       "nodejs",
		Description: "安装 Volta、Node.js LTS、pnpm，并配置 npm 镜像",
		ScriptName:  "nodejs.sh",
	},
	{
		Label:       "uv",
		Description: "安装 uv、配置清华镜像，并安装 Python 3.12",
		ScriptName:  "uv.sh",
	},
	{
		Label:       "conda",
		Description: "安装 Miniforge，并配置 conda 与 pip 镜像",
		ScriptName:  "conda.sh",
	},
	{
		Label:       "java",
		Description: "通过 sdkman 安装 Java 和 Maven",
		ScriptName:  "java.sh",
	},
	{
		Label:       "proxychains",
		Description: "安装 proxychains-ng，并按 GLOBAL_HTTP_PROXY 写入代理配置",
		ScriptName:  "proxychains.sh",
	},
	{
		Label:       "zsh",
		Description: "安装 zsh、oh-my-zsh 和常用插件，并尝试设为默认 shell",
		ScriptName:  "zsh.sh",
	},
}

func RunMenu() error {
	if err := validateInstallEnvironment(); err != nil {
		return err
	}

	options := make([]ui.Option, 0, len(installItems))
	for _, item := range installItems {
		options = append(options, ui.Option{
			Label:       item.Label,
			Description: item.Description,
		})
	}

	index, err := ui.Select("请选择安装项", options)
	if err != nil {
		return err
	}

	return runInstallScript(installItems[index])
}

func validateInstallEnvironment() error {
	if runtime.GOOS == "windows" {
		if os.Getenv("MSYSTEM") != "" {
			return fmt.Errorf("当前环境是 Windows Git Bash，不支持直接执行这些 Linux 安装脚本，请在 Ubuntu 或 WSL 中运行")
		}

		return fmt.Errorf("当前环境是 Windows，不支持直接执行这些 Linux 安装脚本，请在 Ubuntu 或 WSL 中运行")
	}

	return nil
}

func runInstallScript(item Item) error {
	scriptPath, cleanup, err := materializeScript(item.ScriptName)
	if err != nil {
		return err
	}
	defer cleanup()

	fmt.Printf("开始执行 %s\n", item.Label)

	cmd := exec.Command("bash", scriptPath)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Env = os.Environ()

	return cmd.Run()
}
