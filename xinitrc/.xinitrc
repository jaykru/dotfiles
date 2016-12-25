xinput --set-prop "10" "Device Accel Constant Deceleration" 0.5

xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
 
xrandr --dpi 200


#fcitx-autostart
#export XMODIFIERS="@im=fcitx"
#export GTK_IM_MODULE="fcitx"
#export QT_IM_MODULE="fcitx"

[[ -f $HOME/.xmodmaprc ]] && xmodmap $HOME/.xmodmaprc
xflux -z 97201
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
xrdb -load ~/.Xresources
exec bspwm
