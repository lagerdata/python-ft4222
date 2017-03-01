#   ________________     _________________    ________________
#  /                |   /                 |  |                 \
# |    __     __    |  |    ______________|  |    __________    |
# |   |  |   |  |   |  |   |                 |   |          |   |
# |___|  |___|  |   |  |   |______________   |   |          |   |
#  ___    ___   |   |  |                  |  |   |   _______|   |
# |___|  |   |  |   |  |_____________     |  |   |  |           |
#  ___   |___|  |   |                |    |  |   |  |__     ___/
# |___|   ___   |   |   _____________|    |  |   |     \    \
#  ___   |   |  |   |  |                  |  |   |      \    \
# |___|  |___|  |___|  |_________________/   |___|       \____\
#

from enum import IntEnum

class Flag(IntEnum):
    """
    NONE
    START
    REPEATED_START: Repeated_START will not send master code in HS mode
    STOP
    START_AND_STOP: START condition followed by SEND and STOP condition
    """
    NONE = 0x80
    START = 0x02
    REPEATED_START = 0x03  # Repeated_START will not send master code in HS mode
    STOP  = 0x04
    START_AND_STOP = 0x06  # START condition followed by SEND and STOP condition

class ControllerStatus(IntEnum):
    """
    BUSY:  controller busy: all other status bits invalid
    ERROR: error condition
    ADDRESS_NACK: slave address was not acknowledged during last operation
    DATA_NACK: data not acknowledged during last operation
    ARB_LOST: arbitration lost during last operation
    IDLE: controller idle
    BUSY: bus busy
    """
    BUSY = 0x01
    ERROR = 0x02
    ADDRESS_NACK = 0x04
    DATA_NACK = 0x08
    ARB_LOST = 0x10
    IDLE = 0x20
    BUS_BUSY = 0x40
