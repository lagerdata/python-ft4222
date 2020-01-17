#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
#

import sys
import ft4222

nbDev = ft4222.createDeviceInfoList()
print("nb of fdti devices: {}".format(nbDev))

ftDetails = []

if nbDev <= 0:
    print("no devices found...")
    sys.exit(0)

print("devices:")
for i in range(nbDev):
    detail = ft4222.getDeviceInfoDetail(i, False)
    print(" - {}".format(detail))
    ftDetails.append(detail)

dev = ft4222.openByDescription('FT4222 A')
print(dev)

dev.i2cMaster_Init(100)
