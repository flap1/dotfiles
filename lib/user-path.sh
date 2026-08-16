#!/bin/bash
# PATH this repository's tools occupy. Sourced from the processes that look
# up those tools by name. A parent export does not reach a sibling process;
# install.sh and packages/system.sh each set this themselves.

prepend_user_path() {
    PATH="${HOME}/.local/share/mise/shims:${HOME}/.local/bin:${PATH:-}"
    export PATH
}
