export PATH=/home/me/go/bin:$PATH
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export RTC_USE_PIPEWIRE=true
# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    # Start Sway on TTY1
    dbus-run-session sway
elif [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 2 ]; then
    # Start i3 on TTY2
    startx 
fi

# if [ "${XDG_VTNR}" -eq 2 ]; then
#     startx
# fi
