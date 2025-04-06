killall -q swaybg
NEW=$(ls ~/.wallpapers/ | shuf -n 1)
NEW_SWAY_BACK="~/.wallpapers/"$NEW
swaymsg -s $SWAYSOCK output eDP-1 bg $NEW_SWAY_BACK fill
