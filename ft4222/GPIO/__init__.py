from enum import IntEnum

class Trigger(IntEnum):
    """
    RISING, FALLING, LEVEL_HIGH, LEVEL_LOW
    """
    RISING         = 0x01
    FALLING        = 0x02
    LEVEL_HIGH     = 0x04
    LEVEL_LOW      = 0X08
class Output(IntEnum):
    """
    LOW, HIGH
    """
    LOW  = 0
    HIGH = 1
class Port(IntEnum):
    """
    P0, P1, P2, P3
    """
    P0  = 0
    P1  = 1
    P2  = 2
    P3  = 3
class Dir(IntEnum):
    """
    OUTPUT, INPUT
    """
    OUTPUT = 0
    INPUT  = 1
