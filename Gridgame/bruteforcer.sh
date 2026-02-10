#!/bin/bash

# One-liner I used inside my libTAS docker container

i=0 ; while true; do i=$((i+1)) ; echo "Now doing seed $i" ; timeout 720 xvfb-run -a libTAS -i -n -t "$i" -L -r /home/gridgame.ltm --lua lua/gridgame.lua /usr/local/bin/ruffle_desktop -g gl --no-gui /home/gridgame.swf ; done
