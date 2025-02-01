not a huge fan of the og script especially due to it not working (tm)

ustreamer works for me with *some* input sources (output from opiz2w works, output from samsung dex dies after 2 frames)
`ustreamer -m uyvy --host 0.0.0.0 --port=80 --persistent   --workers=4 -T  --device-timeout 5 -r 1280x720 -f 60`

### notes:

`/boot/firmware/config.txt`
```
dtparam=i2c_arm=on # doubt this does anything
dtparam=i2s=on # doubt this does anything
dtparam=spi=on # doubt this does anything
dtparam=i2c_baudrate=10000 # doubt this does anything
dtparam=i2c_vc=on # doubt this does anything

camera_auto_detect=0 # doubt this does anything

dtoverlay=vc4-kms-v3d,cma-512 # doubt this does anything
max_framebuffers=2

[all]
dtoverlay=tc358743,4lane=0 # some of us have the cheap 2lane ones
```


also suggested by ustreamer readme (probably for the gpu encode on rpi4 so might be useless as well)

`/boot/firmware/config.txt`
```
gpu_mem=128
cma=128M
```
