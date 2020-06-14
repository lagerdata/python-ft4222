# python-ft4222

The FT4222H is a High/Full Speed USB2.0-to-Quad SPI/I2C device controller. This project
provides (incomplete) python binding to LibFT4222
([user guide](http://www.ftdichip.com/Support/Documents/AppNotes/AN_329_User_Guide_for_LibFT4222.pdf)).
It provides a similar api than LibFT4222 does.

The complete documentation can be found [here](https://msrelectronics.gitlab.io/python-ft4222/)

## Example

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
