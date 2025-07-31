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
install "https://github.com/koka-community/std" "std" "b5ff42dda3976a9840a1aad2a731dbdc8bd6e7d7"
rm -rf ../std
mv std .. # because it has self-references. and to move it upper in order of includes
install "https://github.com/koka-community/html" "html" "7c97be90e88db69e313c3a19794a5dc786b4b828"