## =========================================================================
## Options
## =========================================================================

unsetopt promptcr

# History
setopt extended_history
setopt append_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space     # a leading space keeps the line out of history
unsetopt hist_verify         # run recalled lines instead of editing them first
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_no_store         # `history` itself is not worth recording
setopt hist_expand
setopt share_history
setopt hist_fcntl_lock       # share_history means concurrent appends

# Completion
setopt list_packed
setopt auto_remove_slash
setopt auto_param_slash
setopt mark_dirs
setopt list_types            # the ls -F markers
unsetopt menu_complete       # list the candidates, do not insert the first
setopt auto_list
setopt auto_menu
setopt auto_param_keys
setopt complete_in_word
setopt magic_equal_subst     # complete after the = in --prefix=/usr
setopt always_last_prompt

# Navigation
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_to_home
setopt pushd_silent
setopt pushdminus            # swap the meaning of + and -

# Globbing and expansion
setopt equals                # =command expands to its path
setopt nonomatch             # an unmatched glob is passed through, not an error
setopt glob
setopt extended_glob
setopt numeric_glob_sort
setopt path_dirs             # search PATH subdirs for names containing /
unsetopt sh_word_split

# Shell behaviour
setopt no_beep
setopt no_flow_control       # C-s and C-q are not flow control here
setopt no_hup                # background jobs survive logout
setopt ignore_eof            # C-d does not end the session
setopt long_list_jobs
setopt multios
setopt print_eight_bit
setopt rm_star_wait          # pause before `rm *`
setopt notify                # report a finished job without waiting for a prompt
unsetopt clobber
setopt interactive_comments
