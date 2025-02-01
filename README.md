not a huge fan of the og script especially due to it not working (tm)

tested working on rpi5 with ustreamer

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

### terrible service
```
[Unit]
Description=ustreamer hdmi input stream
After=network.target
After=systemd-user-sessions.service
After=network-online.target
StartLimitIntervalSec=0

[Service]
WorkingDirectory=/path/to/files/
ExecStart=/path/to/files/hardcoded.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```