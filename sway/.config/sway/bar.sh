DATE=$(date +'%Y-%m-%d %l:%M:%S %p')
BAT=$(cat /sys/class/power_supply/BAT0/capacity)
echo "$DATE | $BAT%"
