//go:build !windows

package system

import "os"

func needSudo() bool {
	return os.Geteuid() != 0
}
