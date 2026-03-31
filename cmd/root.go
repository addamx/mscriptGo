package cmd

import (
	"fmt"
	"os"

	"mscript/internal/ui"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:           "mscript",
	Short:         "mscript 提供常用服务器功能",
	SilenceUsage:  true,
	SilenceErrors: true,
	RunE: func(cmd *cobra.Command, args []string) error {
		return runRootMenu()
	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.AddCommand(newConfigCmd())
	rootCmd.AddCommand(newInstallCmd())
}

func runRootMenu() error {
	ui.PrintHeader("mscript", "服务器常用功能")

	index, err := ui.Select("请选择功能", []ui.Option{
		{Label: "config", Description: "环境配置，当前支持 httpProxy"},
		{Label: "install", Description: "安装常用软件，后续扩展 nodejs、python 等"},
	})
	if err != nil {
		return err
	}

	switch index {
	case 0:
		return runConfigMenu()
	case 1:
		return runInstallMenu()
	}

	return nil
}
