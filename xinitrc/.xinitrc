#export GTK_IM_MODULE=ibus
#export XMODIFIERS=@im=ibus
#export QT_IM_MODULE=ibus
#export GTK_IM_MODULE_FILE=/etc/gtk-2.0/gtk.immodules
#export GTK_IM_MODULE_FILE=/usr/lib/gtk-3.0/3.0.0/immodules.cache

xsetroot -cursor_name left_ptr
xmodmap ~/.xmodmap
#xrandr --dpi 120

# IME
ibus-daemon -x -d

# launch dbus
eval `dbus-launch --auto-syntax`
#xflux -z 97202 # turn down the lights
#export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
xrdb -load $HOME/.Xresources

feh --bg-scale frog.jpg

# font stuff
xset +fp /home/j/.local/share/fonts
xset fp rehash

#sxhkd &
exec i3
