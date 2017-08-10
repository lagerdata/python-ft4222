#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
#

"""Control FTDI USB chips for I2C/SPI/GPIO.

Open a handle using one of the ft4222.openBy... functions and use the methods
on the object thus returned.
"""

from __future__ import absolute_import
from ft4222.ft4222 import *
from ft4222 import *
from enum import IntEnum

__all__ = [
    'createDeviceInfoList',
    'getDeviceInfoDetail',
    'openBySerial',
    'openByDescription',
    'openByLocation'
]

class SysClock(IntEnum):
    """Chip system clock

    Attributes:
        CLK_60: 60 MHz
        CLK_24: 24 MHz
        CLK_48: 48 MHz
        CLK_80: 80 MHz

    """
    CLK_60 = 0
    CLK_24 = 1
    CLK_48 = 2
    CLK_80 = 3
