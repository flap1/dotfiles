## =========================================================================
## Function
## =========================================================================

# -------------------------------------------------------------------------
# rm
# -------------------------------------------------------------------------
function rm-trash() {
	if [ ! -d ~/.local/share/Trash ]; then
		mkdir ~/.local/share/Trash
	fi
	if [ -d ~/.local/share/Trash ]; then
		local date
		date=`date "+%y%m%d-%H%M%S"`
		mkdir ~/.local/share/Trash/$date
		for j in $@; do
			# skip -
			if [ $j[1,1] != "-" ]; then
				# 対象が ~/.local/share/Trash/ 以下なファイルならば /bin/rm を呼び出したいな
				if [ -e $j ]; then
					echo "mv $j ~/.local/share/Trash/$date/"
					command mv $j ~/.local/share/Trash/$date/
				else
					echo "$j : not found"
				fi
			fi
		done
	else
		command rm $@
	fi
}

function delete-trash() {
	local TRASH_DIR="$HOME/.local/share/Trash"
	if [ -d $TRASH_DIR ]; then
		local num=$(ls -1 $TRASH_DIR | wc -l)
		local size=$(du -hs $TRASH_DIR)
		echo "${num} files        $size\n"

		# while true; do
		#   echo -n 'Do you want to delete ~/.local/share/Trash? [y/n]'
		#   read yn
		#   case $yn in
		#     [Yy] ) break;;
		#     [Nn] ) echo 'exit...'; return;;
		#     * ) echo 'Please type[y/n]';;
		#   esac
		# done
		sudo \rm -rf $TRASH_DIR/*
		echo 'Completely deleted!'
	fi
}

# -------------------------------------------------------------------------
# ls
# -------------------------------------------------------------------------
function ls_abbrev() {
	local ls_result
	ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command \
		\ls -1 -CF --show-control-char --color=always | sed $'/^\e\[[0-9;]*m$/d')

	if [ $(echo "$ls_result" | wc -l | tr -d ' ') -gt 50 ]; then
		echo "$ls_result" | head -n 10
		echo '......'
		echo "$ls_result" | tail -n 10
		echo "${fg_bold[yellow]}$(command ls -1 -A | wc -l | tr -d ' ')" \
			"files exist${reset_color}"
	else
		echo "$ls_result"
	fi
}

# -------------------------------------------------------------------------
# directory back/forward ###
# -------------------------------------------------------------------------
path_history=($(pwd))
path_history_index=1
path_history_size=1

function push_path_history() {
local curr_path
curr_path=$1
if [ $curr_path != $path_history[$path_history_index] ]; then
local path_history_cap
path_history_cap=$#path_history
if [ $path_history_index -eq $path_history_cap ]; then
	local next_cap
	next_cap=$(($path_history_cap * 2))
	path_history[$next_cap]=
fi
path_history_index=$(($path_history_index+1))
path_history[$path_history_index]=$curr_path
path_history_size=$path_history_index
fi
}

function dir_back() {
if [ $path_history_index -ne 1 ]; then
path_history_index=$(($path_history_index-1))
local prev_path
prev_path=$path_history[$path_history_index]
echo "cd $prev_path"
cd $prev_path
zle accept-line
fi
}

function dir_forward() {
if [ $path_history_index -ne $path_history_size ]; then
path_history_index=$(($path_history_index+1))
local next_path
next_path=$path_history[$path_history_index]
echo "cd $next_path"
cd $next_path
zle accept-line
fi
}

function reset_path_history() {
path_history=($(pwd))
path_history_index=1
path_history_size=1
}

function chpwd() {
push_path_history $(pwd)
ls_abbrev
}
