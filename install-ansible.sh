#!/bin/bash

set -eu

script_dir="$(dirname "${BASH_SOURCE[0]}")"
setup_venv="$script_dir/venv"
ansible_version=6.3.0

reinstall_ansible() {
    rm -rf "$setup_venv"
    python3 -m venv "$setup_venv"
    "$setup_venv/bin/pip" install ansible=="$ansible_version" boto3 hvac
}

get_ansible_version() {
    "$setup_venv/bin/pip" show ansible | grep 'Version:' | cut -d " " -f 2
}

# make sure ansible is installed and is the right version
if [[ ! -x "$setup_venv/bin/ansible" ]] || [[ "$ansible_version" != "$(get_ansible_version)" ]]; then
    reinstall_ansible
fi
