package profile

import (
	"errors"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"mscript/internal/ui"
)

const (
	proxyBlockStart = "# mscript_httpProxy_start"
	proxyBlockEnd   = "# mscript_httpProxy_end"
)

func ConfigureHTTPProxy() error {
	value, err := ui.PromptText("请输入代理地址", "http://", validateHTTPProxy)
	if err != nil {
		return err
	}

	profilePath, err := resolveProfilePath()
	if err != nil {
		return err
	}

	if err := writeHTTPProxyBlock(profilePath, value); err != nil {
		return err
	}

	fmt.Printf("已更新 %s\n", profilePath)
	return nil
}

func validateHTTPProxy(value string) error {
	parsed, err := url.Parse(value)
	if err != nil {
		return err
	}

	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return fmt.Errorf("仅支持 http 或 https 协议")
	}

	if parsed.Hostname() == "" || parsed.Port() == "" {
		return fmt.Errorf("代理地址需要包含主机和端口，例如 http://127.0.0.1:10792")
	}

	return nil
}

func resolveProfilePath() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}

	return filepath.Join(homeDir, ".profile"), nil
}

func writeHTTPProxyBlock(profilePath, proxyValue string) error {
	content, err := os.ReadFile(profilePath)
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}

	updated := upsertHTTPProxyBlock(string(content), renderHTTPProxyBlock(proxyValue))
	return os.WriteFile(profilePath, []byte(updated), 0644)
}

func renderHTTPProxyBlock(proxyValue string) string {
	return fmt.Sprintf(`%s
export GLOBAL_HTTP_PROXY=%s
proxyon() {
    export http_proxy="$GLOBAL_HTTP_PROXY"
    export https_proxy="$GLOBAL_HTTP_PROXY"
    export ALL_PROXY="$GLOBAL_HTTP_PROXY"
}

proxyoff() {
    unset ALL_PROXY
    unset http_proxy
    unset https_proxy
}
%s
`, proxyBlockStart, proxyValue, proxyBlockEnd)
}

func upsertHTTPProxyBlock(content, block string) string {
	pattern := regexp.MustCompile(`(?s)` + regexp.QuoteMeta(proxyBlockStart) + `.*?` + regexp.QuoteMeta(proxyBlockEnd))
	if pattern.MatchString(content) {
		replaced := pattern.ReplaceAllLiteralString(content, strings.TrimRight(block, "\n"))
		return ensureTrailingNewline(replaced)
	}

	trimmed := strings.TrimRight(content, "\r\n")
	if trimmed == "" {
		return block
	}

	return trimmed + "\n\n" + block
}

func ensureTrailingNewline(content string) string {
	if strings.HasSuffix(content, "\n") {
		return content
	}

	return content + "\n"
}
