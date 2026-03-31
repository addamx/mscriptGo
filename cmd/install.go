package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

func newInstallCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "install",
		Short: "安装常用软件",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runInstallMenu()
		},
	}
}

func runInstallMenu() error {
	fmt.Println("install 功能待实现，后续可接入 nodejs、python 等安装脚本。")
	return nil
}
