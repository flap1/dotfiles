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
		\rm -rf $TRASH_DIR/*
		echo 'Completely deleted!'
	fi
}

