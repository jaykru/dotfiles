DATE = $(date +'%Y-%m-%d %l:%M:%S %p')
BAT = $(acpi | cut -d ' ' -f 4 | head -c -1)
echo $DATE $BAT
