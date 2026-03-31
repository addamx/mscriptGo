#!/bin/bash

set -e

curl -s "https://get.sdkman.io" | bash

if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

sdk install java 8.0.472-zulu
sdk install maven
