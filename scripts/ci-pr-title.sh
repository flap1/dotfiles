#!/usr/bin/env bash
# PR title is the squash commit. Closed type set, English, first letter of
# the description uppercase. No scope: the type is also the label.
# usage: PR_TITLE='feat: Add a thing' scripts/ci-pr-title.sh
#        scripts/ci-pr-title.sh --self-test

set -euo pipefail

check() {
    local title=$1
    local types='feat|fix|imprv|refactor|docs|test|chore'
    if [[ ! $title =~ ^($types):\ [A-Z] ]]; then
        echo "title must match: <type>: <Uppercase description>" >&2
        echo "types: feat, fix, imprv, refactor, docs, test, chore" >&2
        echo "got: $title" >&2
        return 1
    fi
    if [[ $title =~ \.$ ]]; then
        echo "title must not end with a period" >&2
        echo "got: $title" >&2
        return 1
    fi
}

if [ "${1-}" = --self-test ]; then
    check 'feat: Add a thing'
    check 'fix: Pin the catalog'
    check 'docs: Explain install.sh'
    check 'feat: add a thing' 2>/dev/null && exit 1
    check 'feature: Add a thing' 2>/dev/null && exit 1
    check 'feat: Add a thing.' 2>/dev/null && exit 1
    echo 'ci-pr-title self-test ok'
    exit 0
fi

title=${PR_TITLE-}
if [ -z "$title" ]; then
    echo "PR_TITLE is empty" >&2
    exit 2
fi
check "$title"
