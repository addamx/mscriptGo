package ui

import (
	"fmt"
	"strings"

	"github.com/manifoldco/promptui"
)

type Option struct {
	Label       string
	Description string
}

func PrintHeader(title, subtitle string) {
	fmt.Printf("\n%s\n", title)
	fmt.Printf("%s\n\n", subtitle)
}

func Select(title string, options []Option) (int, error) {
	prompt := promptui.Select{
		Label: title,
		Items: options,
		Size:  selectSize(len(options)),
		Templates: &promptui.SelectTemplates{
			Label:    "{{ \"▸\" | cyan }} {{ . | bold }}",
			Active:   "{{ \"●\" | green }} {{ .Label | green | bold }}",
			Inactive: "  {{ .Label }}",
			Selected: "{{ \"✓\" | green }} {{ .Label | bold }}",
			Details: `
--------- 说明 ----------
{{ .Description | faint }}`,
			Help: "{{ \"↑/↓\" | faint }} 选择 {{ \"Enter\" | faint }} 确认 {{ \"/\" | faint }} 搜索",
		},
		Searcher: func(input string, index int) bool {
			option := options[index]
			keyword := strings.ToLower(strings.TrimSpace(input))
			target := strings.ToLower(option.Label + " " + option.Description)
			return strings.Contains(target, keyword)
		},
	}

	index, _, err := prompt.Run()
	return index, err
}

func PromptText(label, defaultValue string, validate func(string) error) (string, error) {
	prompt := promptui.Prompt{
		Label:     label,
		Default:   defaultValue,
		AllowEdit: true,
		Validate:  validate,
		Templates: &promptui.PromptTemplates{
			Prompt:          "{{ \"▸\" | cyan }} {{ . | bold }} ",
			Valid:           "{{ \"●\" | green }} {{ . | bold }} ",
			Invalid:         "{{ \"×\" | red }} {{ . | bold }} ",
			Success:         "{{ . | faint }} ",
			ValidationError: "{{ . | red }}",
		},
	}

	return prompt.Run()
}

func selectSize(length int) int {
	if length < 6 {
		return length
	}

	return 6
}
