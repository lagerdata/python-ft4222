# python-ft4222

The FT4222H is a High/Full Speed USB2.0-to-Quad SPI/I2C device controller. This project
provides (incomplete) python binding to LibFT4222
([user guide](http://www.ftdichip.com/Support/Documents/AppNotes/AN_329_User_Guide_for_LibFT4222.pdf)).
It provides a similar api than LibFT4222 does.

The complete documentation can be found [here](https://msrelectronics.gitlab.io/python-ft4222/)

## Example

### I2C Master

```python
import ft4222
import ft4222.I2CMaster


# list devices
nbDev = ft4222.createDeviceInfoList()
for i in range(nbDev):
    print(ft4222.getDeviceInfoDetail(i, False))

# open device with default description 'FT4222 A'
dev = ft4222.openByDescription('FT4222 A')

# do a i2c transfers where full control is required
slave = 1 # address
# read one byte, don't stop
data = dev.i2cMaster_ReadEx(slave, ft4222.I2CMaster.Flag.REPEATED_START, 1)[0]
# read another 5 bytes
data += dev.i2cMaster_ReadEx(slave, ft4222.I2CMaster.Flag.NONE, 5)
# another byte, than stop
data += dev.i2cMaster_ReadEx(slave, ft4222.I2CMaster.Flag.STOP, 1)
```

### GPIO

```python
import time
import ft4222
from ft4222.GPIO import Dir, Port, Output

# open device with default description 'FT4222 A'
dev = ft4222.openByDescription('FT4222 A')

# use GPIO2 as gpio (not suspend out)
dev.setSuspendOut(False)
# use GPIO3 as gpio (not wakeup)
dev.setWakeUpInterrupt(False)

# init GPIO2 as output
dev.gpio_Init(gpio2 = Dir.OUTPUT)

# generate a square wave signal with GPIO2
while True:
    dev.gpio_Write(Port.P2, output)
    output = not output
    time.sleep(0.1)
```

## Accessrights

Under Linux, the usb device is normally not accessibly by a normal user, therefor
a udev rule is required. Create or extend ``/etc/udev/rules.d/99-ftdi.rules`` to
contain the following text:

```bash
# FTDI's ft4222 USB-I2C Adapter
SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="601c", GROUP="plugdev", MODE="0666"
```
