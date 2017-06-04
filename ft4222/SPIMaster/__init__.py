#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
#

from enum import IntEnum

class Mode(IntEnum):
    """SPIMaster Mode

    Attributes:
        SPI_IO_NONE:
        SPI_IO_SINGLE:
        SPI_IO_DUAL:
        SPI_IO_QUAD:

    """
    NONE   = 0
    SINGLE = 1
    DUAL   = 2
    QUAD   = 4

class Clock(IntEnum):
    """SPIMaster Clock

    Attributes:
        NONE:
        DIV_2: 1/2 System Clock
        DIV_4: 1/4 System Clock
        DIV_8: 1/8 System Clock
        DIV_16: 1/16 System Clock
        DIV_32: 1/32 System Clock
        DIV_64: 1/64 System Clock
        DIV_128: 1/128 System Clock
        DIV_256: 1/256 System Clock
        DIV_512: 1/512 System Clock

    """
    NONE    = 0
    DIV_2   = 1
    DIV_4   = 2
    DIV_8   = 3
    DIV_16  = 4
    DIV_32  = 5
    DIV_64  = 6
    DIV_128 = 7
    DIV_256 = 8
    DIV_512 = 9

class Cpol(IntEnum):
    """SPIMaster Polarisation

    Attributes:
        IDLE_LOW:
        IDLE_HIGH:

    """
    IDLE_LOW  = 0
    IDLE_HIGH = 1

class Cpha(IntEnum):
    """SPIMaster Phase

    Attributes:
        LEADING:
        TRAILING:

    """
    CLK_LEADING  = 0
    CLK_TRAILING = 1
