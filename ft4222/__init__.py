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
from enum import IntEnum
from ft4222.ft4222 import *
from ft4222 import *

__all__ = [
    'createDeviceInfoList',
    'getDeviceInfoDetail',
    'openBySerial',
    'openByDescription',
    'openByLocation'
]
