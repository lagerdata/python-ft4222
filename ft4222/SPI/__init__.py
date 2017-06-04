#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
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
