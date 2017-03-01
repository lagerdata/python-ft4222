"""Control FTDI USB chips for I2C/SPI/GPIO.

Open a handle using one of the ft4222.openBy... functions and use the methods
on the object thus returned.
"""

from ft4222.ft4222 import *
from ft4222 import *

__all__ = [
    'createDeviceInfoList',
    'getDeviceInfoDetail',
    'openBySerial',
    'openByDescription',
    'openByLocation'
]
