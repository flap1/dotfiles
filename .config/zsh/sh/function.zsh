# Functions that must run in the calling shell (cd). Everything else is bin/.

ghcr() {
    local repo="" arg
    for arg in "$@"; do
        case $arg in
            -*) ;;
            *)
                repo=$arg
                break
                ;;
        esac
    done
    [ -n "$repo" ] || {
        print -u2 "usage: ghcr <owner/name> [gh repo create flags]"
        return 2
    }
    gh repo create "$@"
    ghq get -p "$repo"
    nvim "$(ghq list --full-path -e "$repo")"
}

gwc() {
    local root dest
    root=$(git rev-parse --show-toplevel)
    dest="${root/\/ghq\//\/.git-worktrees\/}/$1"
    git worktree add -b "$1" "$dest"
    cd "$dest" || return
    nvim .
}

gwd() {
    local main wt
    main=$(git rev-parse --git-common-dir)
    main=${main%/.git*}
    wt=$(git rev-parse --show-toplevel)
    git worktree remove "$wt"
    cd "$main" || return
    nvim .
}

mkcd() {
    [ $# -eq 1 ] || { print -u2 "usage: mkcd <dir>"; return 2 }
    mkdir -p -- "$1" && builtin cd -- "$1"
}

tsx() {
    [ -z "$1" ] && { echo "usage: tsx PORT [LOCAL_PORT]" >&2; return 1; }
    (( $+commands[tailscale] )) || { echo "tsx: tailscale is not on PATH" >&2; return 1; }
    (( $+commands[socat] )) || { echo "tsx: socat is not on PATH" >&2; return 1; }
    local tsip ts_port local_port
    tsip=$(tailscale ip -4 2>/dev/null) || tsip=""
    [ -z "$tsip" ] && { echo "tsx: no tailscale IPv4 address" >&2; return 1; }
    ts_port="$1"
    local_port="${2:-$1}"
    echo "http://$(hostname -s):${ts_port}  ->  127.0.0.1:${local_port}   (Ctrl-C to stop)"
    socat "TCP-LISTEN:${ts_port},bind=${tsip},fork,reuseaddr" "TCP:127.0.0.1:${local_port}"
}

yy() {
    (( $+commands[yazi] )) || { print -u2 "yy: yazi is not on PATH"; return 1; }
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    command rm -f -- "$tmp"
}
