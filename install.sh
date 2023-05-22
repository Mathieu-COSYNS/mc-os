#!/bin/sh

DIR="$(dirname "$(readlink -f "$0")")"

check_symlink() {
    SRC="$1"
    DEST="$2"

    test -h "$DEST" &&
        test "$(readlink -f "$SRC")" = "$(readlink -f "$DEST")" &&
        return 0

    return 1
}

create_symlink() {
    SRC="$1"
    DEST="$2"

    # Check destination
    test -d "$DEST" &&
        echo "\$2 ($DEST) can not be a directory" 1>&2 &&
        return 1

    check_symlink "$SRC" "$DEST" &&
        echo "$DEST already installed." &&
        return 0

    mkdir -p "$(dirname "$DEST")"

    test -e "$DEST" &&
        echo "Error can not install $DEST because another file already exist at this path." 1>&2 &&
        return 1

    echo "Create $DEST symlink pointing to $SRC"
    ln -s "$SRC" "$DEST"
}

remove_symlink() {
    SRC="$1"
    DEST="$2"

    check_symlink "$SRC" "$DEST" && rm -v "$DEST"

    return 0
}

read_bindings_and_execute() {
    BINDINGS="bindings.csv"
    COMMAND="$1"

    tail -n +2 "$BINDINGS" | awk '{ print NR","$0 }' |
        while IFS="," read -r LINENUMBER SOURCE TARGET || [ -n "$LINENUMBER" ]; do
            test -n "$SOURCE" || echo "Error: SOURCE at line $LINENUMBER in empty" 1>&2
            test -n "$TARGET" || echo "Error: TARGET at line $LINENUMBER in empty" 1>&2

            if test "$(printf %.1s "$TARGET")" = "~"; then
                TARGET="$HOME$(echo "$TARGET" | cut -c1-1 --complement)"
            fi

            $COMMAND "$DIR/src/$SOURCE" "$TARGET"
        done
}

COMMAND="create_symlink"

while getopts "d" OPT; do
    case $OPT in
    d)
        COMMAND="remove_symlink"
        ;;
    *)
        exit 1
        ;;
    esac
    shift
done

read_bindings_and_execute $COMMAND
