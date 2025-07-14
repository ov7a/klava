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
install "https://github.com/koka-community/std" "std" "ab407af3d5fec8a4f48a0a897aacb41c4b556977"
rm -rf ../std
mv std .. # because it has self-references. and to move it upper in order of includes
install "https://github.com/koka-community/html" "html" "c60685deaa95290a24868b95da258ae79670bbc9"