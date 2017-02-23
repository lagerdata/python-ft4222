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

#dev = ft4222.open_by_description(ftDetails[0]['description'])
dev = ft4222.openByLocation(ftDetails[0]['location'])
print(dev)

dev.i2cMaster_Init(250)

res = dev.i2cMaster_Read(2, 1)
print(res)

res = dev.i2cMaster_Write(2, bytes([1,2,3,4]))
print(res)

res = dev.i2cMaster_Read(2, 1)
print(res)

res = dev.i2cMaster_Write(2, bytes([2]*7))
print(res)

res = dev.i2cMaster_Read(2, 4)
print(res)
