#!/usr/bin/env bash

# shellcheck disable=SC2016

# shellcheck disable=SC2034
demo_helper_type_speed=5000

# shellcheck source=./demo-helper.sh
. "$(dirname "$0")/demo-helper.sh"

execute "{
    mkdir /tmp/civo-nav-mco-demo
    cd /tmp/civo-nav-mco-demo
    
    ls -aF /tmp/civo-nav-mco-demo
    cd /tmp/civo-nav-mco-demo
    
    curl -sSL https://codeload.github.com/rytswd/kubecon-eu-2023/tar.gz/main \
        -o kubecon-eu-2023.tar.gz
    
    ls -aF /tmp/civo-nav-mco-demo
}"
