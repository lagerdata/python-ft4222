#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
# SPDX-License-Identifier: MIT
#

"""Control FTDI USB chips for I2C/SPI/GPIO.

Open a handle using one of the ft4222.openBy... functions and use the methods
on the object thus returned.
"""

from __future__ import absolute_import
from .ft4222 import *
from .GPIO import *
from .I2CMaster import *
from .SPI import *
from .SPIMaster import *
from .SPISlave import *

__all__ = [
    'FT2XXDeviceError',
    'FT4222DeviceError',
    'SysClock',
    'createDeviceInfoList',
    'getDeviceInfoDetail',
    'openBySerial',
    'openByDescription',
    'openByLocation',
    'FT4222',
]
