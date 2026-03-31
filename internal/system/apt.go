package system

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"time"
)

const (
	osReleasePath   = "/etc/os-release"
	sourcesListPath = "/etc/apt/sources.list"
	ubuntuMirrorURL = "https://mirrors.aliyun.com/ubuntu/"
)

func ConfigureAPTMirror() error {
	if err := validateAPTEnvironment(); err != nil {
		return err
	}

	fmt.Println("检测系统版本...")

	osInfo, err := readOSRelease()
	if err != nil {
		return err
	}

	version := osInfo["VERSION_ID"]
	if osInfo["ID"] != "ubuntu" {
		return fmt.Errorf("当前仅支持 Ubuntu，检测到系统为 %s", osInfo["ID"])
	}

	codename := resolveUbuntuCodename(osInfo)
	if codename == "" {
		return fmt.Errorf("无法确定 Ubuntu 代号")
	}

	fmt.Printf("系统: ubuntu %s (%s)\n", version, codename)

	backupPath := sourcesListPath + ".backup." + time.Now().Format("20060102_150405")
	if _, err := os.Stat(sourcesListPath); err == nil {
		fmt.Println("备份原有 sources.list...")
		if err := runPrivilegedCommand("cp", sourcesListPath, backupPath); err != nil {
			return err
		}
		fmt.Printf("备份完成: %s\n", backupPath)
	}

	content := renderUbuntuSources(version, codename)
	if err := writePrivilegedFile(sourcesListPath, content); err != nil {
		return err
	}

	fmt.Println("apt 镜像已更新为阿里云源")
	fmt.Println("执行 apt update...")

	if err := runPrivilegedCommand("apt", "update"); err != nil {
		return err
	}

	fmt.Println()
	fmt.Println("完成")
	fmt.Printf("系统: ubuntu %s (%s)\n", version, codename)
	fmt.Printf("镜像: %s\n", ubuntuMirrorURL)
	fmt.Printf("备份: %s\n", backupPath)

	return nil
}

func validateAPTEnvironment() error {
	if runtime.GOOS == "windows" {
		if os.Getenv("MSYSTEM") != "" {
			return fmt.Errorf("当前环境是 Windows Git Bash，不支持直接配置 apt 镜像，请在 Ubuntu 或 WSL 中执行")
		}

		return fmt.Errorf("当前环境是 Windows，不支持直接配置 apt 镜像，请在 Ubuntu 或 WSL 中执行")
	}

	return nil
}

func readOSRelease() (map[string]string, error) {
	content, err := os.ReadFile(osReleasePath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, fmt.Errorf("未找到 %s，请在 Ubuntu 环境中执行 apt 镜像配置", osReleasePath)
		}

		return nil, err
	}

	result := make(map[string]string)
	lines := strings.Split(string(content), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}

		result[parts[0]] = strings.Trim(parts[1], `"`)
	}

	return result, nil
}

func resolveUbuntuCodename(osInfo map[string]string) string {
	if value := osInfo["UBUNTU_CODENAME"]; value != "" {
		return value
	}

	if value := osInfo["VERSION_CODENAME"]; value != "" {
		return value
	}

	switch osInfo["VERSION_ID"] {
	case "24.10":
		return "oracular"
	case "24.04":
		return "noble"
	case "23.10":
		return "mantic"
	case "23.04":
		return "lunar"
	case "22.10":
		return "kinetic"
	case "22.04":
		return "jammy"
	case "20.10":
		return "groovy"
	case "20.04":
		return "focal"
	case "18.04":
		return "bionic"
	}

	return ""
}

func renderUbuntuSources(version, codename string) string {
	now := time.Now().Format("2006-01-02 15:04:05")

	return fmt.Sprintf(`# 阿里云 Ubuntu 镜像源
# 生成时间: %s
# 系统版本: ubuntu %s (%s)

deb %s %s main restricted universe multiverse
deb %s %s-security main restricted universe multiverse
deb %s %s-updates main restricted universe multiverse
deb %s %s-proposed main restricted universe multiverse
deb %s %s-backports main restricted universe multiverse

# deb-src %s %s main restricted universe multiverse
# deb-src %s %s-security main restricted universe multiverse
# deb-src %s %s-updates main restricted universe multiverse
# deb-src %s %s-proposed main restricted universe multiverse
# deb-src %s %s-backports main restricted universe multiverse
`, now, version, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
		ubuntuMirrorURL, codename,
	)
}

func writePrivilegedFile(targetPath, content string) error {
	tempFile, err := os.CreateTemp("", "mscript-apt-*.list")
	if err != nil {
		return err
	}

	tempPath := tempFile.Name()
	defer os.Remove(tempPath)

	if _, err := tempFile.WriteString(content); err != nil {
		tempFile.Close()
		return err
	}

	if err := tempFile.Close(); err != nil {
		return err
	}

	return runPrivilegedCommand("cp", tempPath, targetPath)
}

func runPrivilegedCommand(name string, args ...string) error {
	commandName := name
	commandArgs := args

	if needSudo() {
		commandName = "sudo"
		commandArgs = append([]string{name}, args...)
	}

	cmd := exec.Command(commandName, commandArgs...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Dir = filepath.Dir(sourcesListPath)

	return cmd.Run()
}
