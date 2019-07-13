#!/run/current-system/sw/bin/sh
DATE=$(date +'%Y-%m-%d %l:%M:%S %p')
BAT0=$(cat /sys/class/power_supply/BAT0/capacity)
BAT1=$(cat /sys/class/power_supply/BAT1/capacity)

echo $DATE $BAT0% + $BAT1%
