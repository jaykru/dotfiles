xrandr --dpi 120

#fcitx-autostart
#export XMODIFIERS="@im=fcitx"
#export GTK_IM_MODULE="fcitx"
#export QT_IM_MODULE="fcitx"

# launch dbus
eval `dbus-launch --auto-syntax`
#xflux -z 97202 # turn down the lights
#export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
xrdb -load $HOME/.Xresources

# font stuff
xset +fp /home/j/.local/share/fonts
xset fp rehash

sxhkd &
exec i3
