#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
# SPDX-License-Identifier: MIT
#

from enum import IntEnum

class Flag(IntEnum):
    """I2CMaster Flags

    This flags control the start and stopbit generation during a I2C transfer

    Attributes:
        NONE: No start nor stopbit
        START: Startbit
        REPEATED_START: Repeated startbit (will not send master code in HS mode)
        STOP: Stopbit
        START_AND_STOP: Startbit and stopbit

    """
    NONE = 0x80
    START = 0x02
    REPEATED_START = 0x03  # Repeated_START will not send master code in HS mode
    STOP  = 0x04
    START_AND_STOP = 0x06  # START condition followed by SEND and STOP condition

class ControllerStatus(IntEnum):
    """I2CMaster controller Status

    Attributes:
        BUSY:  controller busy: all other status bits invalid
        ERROR: error condition
        ADDRESS_NACK: slave address was not acknowledged during last operation
        DATA_NACK: data not acknowledged during last operation
        ARB_LOST: arbitration lost during last operation
        IDLE: controller idle
        BUS_BUSY: bus busy

    """
    BUSY = 0x01
    ERROR = 0x02
    ADDRESS_NACK = 0x04
    DATA_NACK = 0x08
    ARB_LOST = 0x10
    IDLE = 0x20
    BUS_BUSY = 0x40
