#!/bin/bash



#scuffed pls dont use





MEDIADEVICE=-1
#SELECT RESOLUTION VALID VALUES (720p60edid, 1080p25edid, 1080p30edid, 1080p50edid, 1080p60edid)
VIDEDID=720p60edid

# RGB888_1X24 = RGB3
# UYVY8_1X16 = UYVY
VIDEOFORMAT=UYVY8_1X16

# if VIDEOID starts with 1080, width=1920,height=1080
# if VIDEOID starts with 720, width=1280,height=720
WIDTH=1920
HEIGHT=1080
if [[ "${VIDEDID:0:3}" = "720" ]]; then
    WIDTH=1280
    HEIGHT=720
fi
RESOLUTION=$(echo "$WIDTH"x"$HEIGHT")
# Finding Media Device
i=0
while true; do
    MEDIADEVICE=$(udevadm info -a -n /dev/media$i | grep --line-buffered 'DRIVERS=="\rp1-cfe"' | while read -r line; do echo $i; done)
    if ! [[ $MEDIADEVICE = '' ]]; then
        break
    fi
    i=$((i + 1))
done

# mine was NOT tc358743 4-000f, instead was tc358743 11-000f
DEVICEPAD=$(media-ctl -d /dev/media0 -p | grep -o 'tc358743 [0-9]*\-[0-9]*f' | head -n1)

# if $VIDEOFORMAT == RGB888_1X24, then pixelformat RGB3
# if $VIDEOFORMAT == UYVY8_1X16, then pixelformat UYVY

if [ $VIDEOFORMAT == "RGB888_1X24" ]; then
    PIXELFORMAT=RGB3
else
    PIXELFORMAT=UYVY
fi

# echo all vars
echo "MEDIADEVICE: $MEDIADEVICE"
echo "VIDEDID: $VIDEDID"
echo "VIDEOFORMAT: $VIDEOFORMAT"
echo "WIDTH: $WIDTH"
echo "HEIGHT: $HEIGHT"
echo "DEVICEPAD: $DEVICEPAD"
echo "PIXELFORMAT: $PIXELFORMAT"
echo "setting in 2s, make sure something is outputting to the hdmi input"
sleep 2s

# Loading Driver
v4l2-ctl -d /dev/v4l-subdev2 --set-edid=file=$VIDEDID --fix-edid-checksums
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
media-ctl -d /dev/media$MEDIADEVICE -V ''\''csi2'\'':0 [fmt:'$VIDEOFORMAT'/'$RESOLUTION' field:none colorspace:srgb]'
media-ctl -d /dev/media$MEDIADEVICE -V ''\''csi2'\'':4 [fmt:'$VIDEOFORMAT'/'$RESOLUTION' field:none colorspace:srgb]'

media-ctl -d /dev/media$MEDIADEVICE -V ''\'''$DEVICEPAD''\'':0 [fmt:'$VIDEOFORMAT'/'$RESOLUTION' field:none colorspace:srgb]'

#Set the output format.
v4l2-ctl -v width=$WIDTH,height=$HEIGHT,pixelformat=$PIXELFORMAT

# # test frames
# v4l2-ctl --stream-mmap=3 --stream-count=10 --stream-to=/dev/null

# ustreamer working great on rpi5 with *some* inputs
# ustreamer -m uyvy --host 0.0.0.0 --port=80 --persistent   --workers=4 -T  --device-timeout 5 -r 1280x720 -f 60