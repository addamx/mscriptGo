package cmd

import (
	installer "mscript/internal/install"

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
	return installer.RunMenu()
}
