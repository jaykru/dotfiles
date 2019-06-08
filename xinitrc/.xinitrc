#xinput set-prop "TPPS/2 IBM TrackPoint" "Device Accel Constant Deceleration" 0.5
#xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
#xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
#xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
#xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
 
xrandr --dpi 120

#fcitx-autostart
#export XMODIFIERS="@im=fcitx"
#export GTK_IM_MODULE="fcitx"
#export QT_IM_MODULE="fcitx"

# launch dbus
eval `dbus-launch --auto-syntax`
xmodmap $HOME/.xmodmaprc
#xflux -z 97202 # turn down the lights
#export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
feh --bg-scale $HOME/Downloads/oldman.jpg
xrdb -load $HOME/.Xresources

# font stuff
xset +fp /home/j/.local/share/fonts
xset fp rehash


exec xmonad
