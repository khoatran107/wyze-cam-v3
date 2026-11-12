mkdir /media/mmc
mount /dev/mmcblk0p1 /media/mmc
echo "hihi" > /media/mmc/hahaha

ifconfig wlan0 up
wpa_supplicant -c /media/mmc/door/wpa_supplicant.conf -i wlan0 > /media/mmc/output.log 2>&1 &
udhcpc -i wlan0

# /media/mmc/door/revshell.sh &
/media/mmc/door/start.sh 
# /media/mmc/door/bindshell.sh &
