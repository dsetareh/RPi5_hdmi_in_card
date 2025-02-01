#!/bin/bash

MEDIADEVICE=-1
#SELECT RESOLUTION VALID VALUES (720p60edid, 1080p25edid, 1080p30edid, 1080p50edid, 1080p60edid)

# hardcoded+works4me, important to change tc358743 11-000f to your device

i=0
while true; do
    MEDIADEVICE=$(udevadm info -a -n /dev/media$i | grep --line-buffered 'DRIVERS=="\rp1-cfe"' | while read -r line; do echo $i; done)
    if ! [[ $MEDIADEVICE = '' ]]; then
        break
    fi
    i=$((i + 1))
done

# Loading Driver
v4l2-ctl -d /dev/v4l-subdev2 --set-edid=file=1080p50edid --fix-edid-checksums
# Wait drive loads
sleep 5s

# To query the current input source information, if the resolution displays as 0, it indicates that no input source signal has been detected. In this case, you should check the hardware connections and follow the steps mentioned above to troubleshoot.
v4l2-ctl -d /dev/v4l-subdev2 --query-dv-timings
# Confirm the current input source information.
v4l2-ctl -d /dev/v4l-subdev2 --set-dv-bt-timings query

# Initialize media
media-ctl -d /dev/media$MEDIADEVICE -r
# Connect CSI2's pad4 to rp1-cfe-csi2_ch0's pad0.
media-ctl -d /dev/media$MEDIADEVICE -l ''\''csi2'\'':4 -> '\''rp1-cfe-csi2_ch0'\'':0 [1]'
# Configure the media node.
media-ctl -d /dev/media$MEDIADEVICE -V ''\''csi2'\'':0 [fmt:UYVY8_1X16/1920x1080 field:none colorspace:srgb]'
media-ctl -d /dev/media$MEDIADEVICE -V ''\''csi2'\'':4 [fmt:UYVY8_1X16/1920x1080 field:none colorspace:srgb]'

media-ctl -d /dev/media$MEDIADEVICE -V ''\''tc358743 11-000f'\'':0 [fmt:UYVY8_1X16/1920x1080 field:none colorspace:srgb]'

#Set the output format.
v4l2-ctl -v width=1920,height=1080,pixelformat=UYVY

echo "MEDIADEVICE: /dev/media$MEDIADEVICE"

# # test frames
# v4l2-ctl --stream-mmap=3 --stream-count=10 --stream-to=/dev/null

HEIGHT=$(v4l2-ctl -d /dev/v4l-subdev2 --query-dv-timings | grep 'Active height' | awk '{print $3}')
WIDTH=$(v4l2-ctl -d /dev/v4l-subdev2 --query-dv-timings | grep 'Active width' | awk '{print $3}')

# ustreamer working great on rpi5 with *some* inputs
# important to be the same res as dv-timings
# ustreamer --dv-timings flag not working for me
ustreamer -m uyvy --host 0.0.0.0 --port=80 --persistent --workers=4 -T --device-timeout 5 -r "$WIDTH"x"$HEIGHT" -f 50
