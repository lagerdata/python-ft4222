#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
# SPDX-License-Identifier: MIT
#

from enum import IntEnum

class DrivingStrength(IntEnum):
    """SPIMaster Driving Strength

    Attributes:
        DS4MA:
        DS8MA:
        DS12MA:
        DS16MA:

    """
    DS4MA  = 0
    DS8MA  = 1
    DS12MA = 2
    DS16MA = 3

class Cpol(IntEnum):
    """SPIMaster Polarisation

    Attributes:
        IDLE_LOW: Idle low
        IDLE_HIGH: Idle high

    """
    IDLE_LOW  = 0
    IDLE_HIGH = 1

class Cpha(IntEnum):
    """SPIMaster Phase

    Attributes:
        CLK_LEADING: Leading phase
        CLK_TRAILING: Trailing phase

    """
    CLK_LEADING  = 0
    CLK_TRAILING = 1
