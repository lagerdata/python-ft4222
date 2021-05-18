#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
# SPDX-License-Identifier: MIT
#

"""SPI Slave

Definitions to configure the SPI Slave interface.
"""

from enum import IntEnum

class Protocol(IntEnum):
    """SPI SLAVE protocol

    Attributes:
        SPI_SLAVE_WITH_PROTOCOL: With the full SPI SLAVE PROTOCOL supported
        SPI_SLAVE_NO_PROTOCOL: Remove SPI SLAVE protocol, users can design their own protocol
        SPI_SLAVE_NO_ACK: Retain SPI SLAVE protocol but remove command ‘ACK’

    """
    SPI_SLAVE_WITH_PROTOCOL = 0
    SPI_SLAVE_NO_PROTOCOL   = 1
    SPI_SLAVE_NO_ACK        = 2
