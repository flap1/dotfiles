#!/bin/bash

function gdrive_download () {
ID=`echo $1 | sed -e "s/^https\:\/\/drive\.google\.com\/file\/d\/\(.*\)\/.*$/\1/"`
CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
	"https://docs.google.com/uc?export=download&id=$ID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM&id=$ID" -O $2
rm -rf /tmp/cookies.txt
}

gdrive_download https://drive.google.com/file/d/1YiOxt3_V-ezSxgIVFwn2s5gGCRQfA0hK/view?usp=share_link .config/pictures/Monterey2.png
