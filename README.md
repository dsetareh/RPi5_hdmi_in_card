not a huge fan of og script especially due to it not working (tm)

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

