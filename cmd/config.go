package cmd

import (
	"mscript/internal/profile"
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
	})
	if err != nil {
		return err
	}

	if index == 0 {
		return profile.ConfigureHTTPProxy()
	}

	return nil
}
