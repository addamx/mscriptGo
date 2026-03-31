//go:build windows

package system

func needSudo() bool {
	return false
}
