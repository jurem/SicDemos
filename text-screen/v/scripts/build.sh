#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

printhelp() {
    echo -e "USAGE:"
    echo -e "${RED}build from files:${NC} $0 files file1.a file2.b ..."
    echo -e "${RED}build project:${NC} $0 project"
    exit 1
}

build_files() {
    # copy .asm files
    echo "[build] Copying files..."
    cp "$@" .

    # compile .asm files
    objs=()
    for f in "$@"; do
        base="$(basename "$f")"
        echo "[build] Assembling ${base}"
        java -cp sictools.jar sic.Asm "$base"

        obj="${base%.asm}.obj"
        objs+=( "$obj" )
    done

    # link .obj files
    echo "[build] Linking..."
    java -cp sictools.jar sic.Link -o out.obj "${objs[@]}"

    # remove everything but out.obj
    echo "[build] Cleaning up..."
    for o in *.obj; do
        [[ "$o" == "out.obj" ]] && continue
        rm -f "$o"
    done
    rm -f *.asm *.lst *.log
}

if [[ "$1" == "files" ]]; then
    if [ ! -f sictools.jar ]; then
        echo "sictools.jar not found! Make sure to copy it here from SicTools (https://github.com/jurem/SicTools)"
        exit 2
    fi

    shift # exclude "files"

    if [[ -z "$1" ]]; then printhelp; fi
    build_files "$@"

elif [[ "$1" == "project" ]]; then
    if [ ! -f sictools.jar ]; then
        echo "sictools.jar not found! Make sure to copy it here from SicTools (https://github.com/jurem/SicTools)"
        exit 2
    fi
    if [ ! -d ../src ]; then
        echo "src directory not found! Make sure to run $0 in PROJECT_ROOT/scripts"
        exit 3
    fi

    asm_files=()
    asm_files+=( "../src/init.asm" )
    [[ -f ../vconf.asm ]] && asm_files+=( "../vconf.asm" )
    asm_files+=( "../src/loop.asm" )
    asm_files+=( "../src/v.asm" )
    asm_files+=( "../src/inout.asm" )
    asm_files+=( "../src/map.asm" )
    asm_files+=( "../src/stack.asm" )

    build_files "${asm_files[@]}"

else
    printhelp
fi

