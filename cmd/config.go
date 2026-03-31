package cmd

import (
	"mscript/internal/profile"
	aptconfig "mscript/internal/system"
	"mscript/internal/ui"

	"github.com/spf13/cobra"
)

func newConfigCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "config",
		Short: "配置环境",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runConfigMenu()
		},
	}
}

func runConfigMenu() error {
	index, err := ui.Select("请选择配置项", []ui.Option{
		{Label: "配置 httpProxy", Description: "写入或替换 ~/.profile 中的代理函数块"},
		{Label: "配置 apt 镜像", Description: "替换 Ubuntu 的 /etc/apt/sources.list 为阿里云镜像并执行 apt update"},
	})
	if err != nil {
		return err
	}

	switch index {
	case 0:
		return profile.ConfigureHTTPProxy()
	case 1:
		return aptconfig.ConfigureAPTMirror()
	}

	return nil
}
