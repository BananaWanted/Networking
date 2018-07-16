#!/usr/bin/env bash
set -e
set -o pipefail

if [[ $(uname -s) = "Darwin" ]]; then
    brew install kubernetes-helm
else
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
fi

kubectl cluster-info --request-timeout=10 2>/dev/null | head -n 1

init_cmd="helm init"

echo run $init_cmd? [y/n]
read response

if [[ $response = y* ]]; then
    $init_cmd
fi

