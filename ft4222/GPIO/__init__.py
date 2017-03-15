#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
#

from enum import IntEnum

class Trigger(IntEnum):
    """GPIO Trigger in 'interrupt' mode

    Attributes:
        RISING: Rising edge
        FALLING: Falling edge
        LEVEL_HIGH: High level
        LEVEL_LOW: Low level

    """
    RISING         = 0x01
    FALLING        = 0x02
    LEVEL_HIGH     = 0x04
    LEVEL_LOW      = 0X08

class Output(IntEnum):
    """GPIO Output

    Attributes:
        LOW: Logic low, 0
        HIGH: Logic high, 1

    """
    LOW  = 0
    HIGH = 1

class Port(IntEnum):
    """GPIO Port

    Attributes:
        P0: Port 0
        P1: Port 1
        P2: Port 2
        P3: Port 3

    """
    P0  = 0
    P1  = 1
    P2  = 2
    P3  = 3

class Dir(IntEnum):
    """GPIO Output direction

    Attributes:
        OUTPUT: Use as output
        INPUT: Use as input

    """
    OUTPUT = 0
    INPUT  = 1
