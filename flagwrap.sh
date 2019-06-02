#!/bin/bash

declare -A replacable=( \
  [--duplex]="" \
  [--foo]="bar" \
  [--x]="y" \
)

declare -A appendable=( \
  [--broker_arg]="" \
  [--root_arg]="" \
  [--leaf_arg]="" \
)

function set_user_flag {
    local canonical="$1"
    if [[ "${canonical}" =~ --no ]]; then
        canonical="--${canonical#--no}=false"
    fi
    IFS='=' read -r key value  <<< "${canonical}"
    if [[ -n "${appendable[${key}]+APPEND}" ]]; then
        appendable["${key}"]+=" ${value}"
    else
        replacable["${key}"]="${value}"
    fi
}

function main {
    for kv in "$@"; do
        set_user_flag "${kv}"
    done
    local -a argv=( "target" )
    for key in "${!replacable[@]}"; do
        local value="${replacable[$key]}"
        if [[ -n "${value}" ]]; then
            argv+=( "${key}=${value}" )
        else
            argv+=( "${key}" )
        fi
    done
    for key in "${!appendable[@]}"; do
        for value in ${appendable["${key}"]}; do
            argv+=( "${key}=${value}")
        done
    done
    for a in "${argv[@]}"; do
        echo "  " ${a} "\\"
    done
}

main "$@"
