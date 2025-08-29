#!/bin/bash
set -eu

function install {
    local repo="$1"
    local path="$2"
    local hash="$3"
    local dir=$(basename "$path")

    rm -rf "$dir"
    git clone --no-checkout --filter=tree:0 $repo $dir
    cd $dir
    git reset --hard $hash
    git sparse-checkout set --no-cone "/$path"
    git checkout
    local subdir=$(echo "$path" | cut -d'/' -f1)
    mv "$path"/* .
    rm -rf "$subdir"
    cd -
}

mkdir -p "libs"
cd "libs"
install "https://github.com/koka-community/std" "std" "6398eb3af8c7d50c24573f391a4dede45cd342a6"
install "https://github.com/koka-community/html" "html" "7c97be90e88db69e313c3a19794a5dc786b4b828"