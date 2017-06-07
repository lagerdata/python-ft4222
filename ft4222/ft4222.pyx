#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
#

from ft4222.cftd2xx cimport *
from ft4222.clibft4222 cimport *
from cpython.array cimport array, resize
from libc.stdio cimport printf
from GPIO import Dir, Trigger

cdef extern from "<alloca.h>" nogil:
    void *alloca(size_t size)

__ftd2xx_msgs = ['OK', 'INVALID_HANDLE', 'DEVICE_NOT_FOUND', 'DEVICE_NOT_OPENED',
                 'IO_ERROR', 'INSUFFICIENT_RESOURCES', 'INVALID_PARAMETER',
                 'INVALID_BAUD_RATE', 'DEVICE_NOT_OPENED_FOR_ERASE',
                 'DEVICE_NOT_OPENED_FOR_WRITE', 'FAILED_TO_WRITE_DEVICE0',
                 'EEPROM_READ_FAILED', 'EEPROM_WRITE_FAILED', 'EEPROM_ERASE_FAILED',
                 'EEPROM_NOT_PRESENT', 'EEPROM_NOT_PROGRAMMED', 'INVALID_ARGS',
                 'NOT_SUPPORTED', 'OTHER_ERROR', 'DEVICE_LIST_NOT_READY']

__ftd4222_msgs = ['DEVICE_NOT_SUPPORTED', 'CLK_NOT_SUPPORTED','VENDER_CMD_NOT_SUPPORTED',
                  'IS_NOT_SPI_MODE', 'IS_NOT_I2C_MODE', 'IS_NOT_SPI_SINGLE_MODE',
                  'IS_NOT_SPI_MULTI_MODE', 'WRONG_I2C_ADDR', 'INVAILD_FUNCTION',
                  'INVALID_POINTER', 'EXCEEDED_MAX_TRANSFER_SIZE', 'FAILED_TO_READ_DEVICE',
                  'I2C_NOT_SUPPORTED_IN_THIS_MODE', 'GPIO_NOT_SUPPORTED_IN_THIS_MODE',
                  'GPIO_EXCEEDED_MAX_PORTNUM', 'GPIO_WRITE_NOT_SUPPORTED',
                  'GPIO_PULLUP_INVALID_IN_INPUTMODE', 'GPIO_PULLDOWN_INVALID_IN_INPUTMODE',
                  'GPIO_OPENDRAIN_INVALID_IN_OUTPUTMODE', 'INTERRUPT_NOT_SUPPORTED',
                  'GPIO_INPUT_NOT_SUPPORTED', 'EVENT_NOT_SUPPORTED', 'FUN_NOT_SUPPORT']


# Revision A chips report chipVersion as 0x42220100; revision B chips report
# 0x42220200; revision C chips report 0x42220300. Revision B chips require
# version 1.2 or later of LibFT4222, indicated by dllVersion being greater than
# 0x01020000; Revision C chips require version 1.3 or later of LibFT4222, indicated
# by dllVersion being greater than 0x01030000.
__chip_rev_map = { 0x42220100: "Rev. A", 0x42220200: "Rev. B", 0x42220300: "Rev. C" }
__chip_rev_min_lib = { 0x42220100: 0, 0x42220200: 0x01020000, 0x42220300: 0x01030000 }


DEF MAX_DESCRIPTION_SIZE = 256

class FT2XXDeviceError(Exception):
    """Exception class for status messages"""
    def __init__(self, msgnum):
        self.message = __ftd2xx_msgs[msgnum]

    def __str__(self):
        return self.message

class FT4222DeviceError(FT2XXDeviceError):
    """Exception class for status messages"""
    def __init__(self, msgnum):
        if msgnum >= FT4222_DEVICE_NOT_SUPPORTED:
            self.message = __ftd4222_msgs[msgnum - FT4222_DEVICE_NOT_SUPPORTED]
        else:
            super(FT4222DeviceError, self).__init__(msgnum)

    def __str__(self):
        return self.message

def createDeviceInfoList():
    """Create the internal device info list and return number of entries"""
    cdef DWORD nb
    status = FT_CreateDeviceInfoList(&nb)
    if status == FT_OK:
        return nb
    raise FT2XXDeviceError, status

def getDeviceInfoDetail(devnum=0, update=True):
    """Get an entry from the internal device info list. Set update to
    False to avoid a slow call to createDeviceInfoList."""
    cdef:
        DWORD f, t, i, l
        FT_HANDLE h
        char n[MAX_DESCRIPTION_SIZE]
        char d[MAX_DESCRIPTION_SIZE]
    # createDeviceInfoList is slow, only run if update is True
    if update: createDeviceInfoList()
    status = FT_GetDeviceInfoDetail(devnum, &f, &t, &i, &l, n, d, &h)
    if status == FT_OK:
        return {'index': devnum, 'flags': f, 'type': t,
                'id': i, 'location': l, 'serial': n,
                'description': d, 'handle': <size_t>h}
    raise FT2XXDeviceError, status

def openBySerial(serial):
    """Open a handle to a usb device by serial number"""
    cdef FT_HANDLE handle
    cdef char* cserial = serial
    status = FT_OpenEx(<PVOID>cserial, FT_OPEN_BY_SERIAL_NUMBER, &handle)
    if status == FT_OK:
        return FT4222(<uintptr_t>handle, update=False)
    raise FT2XXDeviceError, status

def openByDescription(desc):
    """Open a handle to a usb device by description

    Args:
        desc (bytes, str): Description of the device

    Returns:
        FT4222: Opened device

    Raises:
        FT2XXDeviceError: on error

    """
    if isinstance(desc, str):
        desc = desc.encode('utf-8')
    cdef FT_HANDLE handle
    cdef char* cdesc = desc
    status = FT_OpenEx(<PVOID>cdesc, FT_OPEN_BY_DESCRIPTION, &handle)
    if status == FT_OK:
        #printf("handle: %d\n", handle)
        return FT4222(<uintptr_t>handle, update=False)
    raise FT2XXDeviceError, status

def openByLocation(locId):
    """Open a handle to a usb device by location

    Args:
        locId (int): Location id

    Returns:
        FT4222: Opened device

    Raises:
        FT2XXDeviceError: on error

    """
    cdef FT_HANDLE handle
    status = FT_OpenEx(<PVOID><uintptr_t>locId, FT_OPEN_BY_LOCATION, &handle)
    if status == FT_OK:
        return FT4222(<uintptr_t>handle, update=False)
    raise FT2XXDeviceError, status


cdef class FT4222:
    cdef FT_HANDLE handle
    cdef DWORD chip_version
    cdef DWORD dll_version

    def __init__(self, handle, update=True):
        self.handle = <FT_HANDLE><uintptr_t>handle
        self.chip_version = 0
        self.dll_version = 0
        self.__get_version()

    def __del__(self):
        if self.handle != NULL:
            FT_Close(self.handle)

    def close(self):
        """Closes the device."""
        status = FT4222_UnInitialize(self.handle)
        if status != FT4222_OK:
            raise FT4222DeviceError, status
        status = FT_Close(self.handle)
        if status != FT4222_OK:
            raise FT4222DeviceError, status
        self.handle = NULL

    cdef __get_version(self):
        cdef FT4222_Version ver
        status = FT4222_GetVersion(self.handle, &ver)
        if status == FT4222_OK:
            self.chip_version = ver.chipVersion
            self.dll_version = ver.dllVersion

    @property
    def chipVersion(self) -> int:
        """Chip version as number"""
        return self.chip_version

    @property
    def libVersion(self) -> int:
        """Library version as number"""
        return self.dll_version

    def chipRevision(self) -> str:
        """Get the revision of the chip in human readable format

        Returns:
            str: chip revision

        """
        try:
            return __chip_rev_map[self.chip_version]
        except KeyError:
            return "Rev. unknown"

    def __repr__(self):
        return "FT4222: chipVersion: 0x{:x} ({:s}), libVersion: 0x{:x}".format(self.chip_version, self.chipRevision(), self.dll_version)


    def gpio_Init(self, *args, gpio0=Dir.INPUT, gpio1=Dir.INPUT, gpio2=Dir.INPUT, gpio3=Dir.INPUT):
        """Initialize the GPIO interface.

        Args:
            *args (list, optional): List containing a direction "(ft4222.GPIO.Dir)" for each port.
            gpio0 (ft4222.GPIO.Dir): Direction of gpio0
            gpio1 (ft4222.GPIO.Dir): Direction of gpio1
            gpio2 (ft4222.GPIO.Dir): Direction of gpio2
            gpio3 (ft4222.GPIO.Dir): Direction of gpio3

        Raises:
            FT4222DeviceError: on error

        """
        cdef:
            GPIO_Dir ioDir[4]
        if len(args) > 0:
            for i in xrange(len(args)):
                ioDir[i] = args[i]
            for i in xrange(len(args), 4 - len(args)):
                ioDir[i] = GPIO_OUTPUT
        else:
            ioDir[0] = gpio0
            ioDir[1] = gpio1
            ioDir[2] = gpio2
            ioDir[3] = gpio3
        status = FT4222_GPIO_Init(self.handle, ioDir)
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def gpio_Read(self, portNum):
        cdef:
            BOOL value
        status = FT4222_GPIO_Read(self.handle, portNum, &value)
        if status == FT4222_OK:
            return value
        raise FT4222DeviceError, status

    def gpio_Write(self, portNum, value):
        status = FT4222_GPIO_Write(self.handle, portNum, value)
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def gpio_SetInputTrigger(self, portNum, trigger):
        status = FT4222_GPIO_SetInputTrigger(self.handle, portNum, trigger)
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def gpio_GetTriggerStatus(self, portNum):
        cdef:
            uint16 queueSize
        status = FT4222_GPIO_GetTriggerStatus(self.handle, portNum, &queueSize)
        if status == FT4222_OK:
            return queueSize
        raise FT4222DeviceError, status

    def gpio_ReadTriggerQueue(self, portNum, readSize=None):
        if readSize == None:
            self.gpio_GetTriggerStatus(portNum)
        cdef:
            GPIO_Trigger *events = <GPIO_Trigger*>alloca(portNum * sizeof(GPIO_Trigger))
            uint16 sizeRead
        status = FT4222_GPIO_ReadTriggerQueue(self.handle, portNum, events, readSize, &sizeRead)
        if status == FT4222_OK:
            res = []
            for i in xrange(readSize):
                res.append(Trigger(events[i]))
            return res
        raise FT4222DeviceError, status


    def i2cMaster_Init(self, kbps=100):
        """Initialize the FT4222H as an I2C master with the requested I2C speed.

        Args:
            kbps (int): Speed in kb/s

        Raises:
            FT4222DeviceError: on error

        """
        status = FT4222_I2CMaster_Init(self.handle, kbps)
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def i2cMaster_Read(self, addr, bytesToRead):
        """Read data from the specified I2C slave device with START and STOP conditions.

        Args:
            addr (int): I2C slave address
            bytesToRead (int): Number of bytes to read from slave

        Returns:
            bytes: Bytes read from slave

        Raises:
            FT4222DeviceError: on error

        """
        cdef:
            array[uint8] buf = array('B', [])
            uint16 bytesRead
        resize(buf, bytesToRead)
        status = FT4222_I2CMaster_Read(self.handle, addr, buf.data.as_uchars, bytesToRead, &bytesRead)
        resize(buf, bytesRead)
        if status == FT4222_OK:
            return bytes(buf)
        raise FT4222DeviceError, status

    def i2cMaster_Write(self, addr, data):
        """Write data to the specified I2C slave device with START and STOP conditions.

        Args:
            addr (int): I2C slave address
            data (int, bytes, bytearray): Data to write to slave

        Returns:
            int: Bytes sent to slave

        Raises:
            FT4222DeviceError: on error

        """
        if isinstance(data, int):
            data = bytes([data])
        elif not isinstance(data, (bytes, bytearray)):
            raise TypeError("the data argument must be of type 'int', 'bytes' or 'bytearray'")
        cdef:
            uint16 bytesSent
            uint8* cdata = data
        status = FT4222_I2CMaster_Write(self.handle, addr, cdata, len(data), &bytesSent)
        if status == FT4222_OK:
            return bytesSent
        raise FT4222DeviceError, status

    def i2cMaster_ReadEx(self, addr, flag, bytesToRead):
        """Read data from the specified I2C slave device with the specified I2C condition.

        Args:
            addr (int): I2C slave address
            flag (ft4222.I2CMaster.Flag): Flag to control start- and stopbit generation
            bytesToRead (int): Number of bytes to read from slave

        Returns:
            bytes: Bytes read from slave

        Raises:
            FT4222DeviceError: on error

        """
        cdef:
            array[uint8] buf = array('B', [])
            uint16 bytesRead
        resize(buf, bytesToRead)
        status = FT4222_I2CMaster_ReadEx(self.handle, addr, flag, buf.data.as_uchars, bytesToRead, &bytesRead)
        resize(buf, bytesRead)
        if status == FT4222_OK:
            return bytes(buf)
        raise FT4222DeviceError, status

    def i2cMaster_WriteEx(self, addr, flag, data):
        """Write data to the specified I2C slave device with the specified I2C condition.

        Args:
            addr (int): I2C slave address
            flag (ft4222.I2CMaster.Flag): Flag to control start- and stopbit generation
            data (int, bytes, bytearray): Data to write to slave

        Returns:
            int: Bytes sent to slave

        Raises:
            FT4222DeviceError: on error

        """
        if isinstance(data, int):
            data = bytes([data])
        elif not isinstance(data, (bytes, bytearray)):
            raise TypeError("the data argument must be of type 'int', 'bytes' or 'bytearray'")
        cdef:
            uint16 bytesSent
            uint8* cdata = data
        status = FT4222_I2CMaster_WriteEx(self.handle, addr, flag, cdata, len(data), &bytesSent)
        if status == FT4222_OK:
            return bytesSent
        raise FT4222DeviceError, status

    def i2cMaster_Reset(self):
        """Reset the I2C master device.

        If the I2C bus encounters errors or works abnormally, this function will reset the I2C device.
        It is not necessary to call I2CMaster_Init again after calling this reset function.

        Raises:
            FT4222DeviceError: on error

        """
        status = FT4222_I2CMaster_Reset(self.handle)
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def i2cMaster_GetStatus(self):
        """Read the status of the I2C master controller.

        This can be used to poll a slave until its write-cycle is complete.

        Returns:
            ft4222.I2CMaster.ControllerStatus: Controller status

        Raises:
            FT4222DeviceError: on error

        """
        cdef uint8 cs
        status = FT4222_I2CMaster_GetStatus(self.handle, &cs)
        if status == FT4222_OK:
            return cs
        raise FT4222DeviceError, status


    def spi_Reset(self):
        """Reset the SPI master or slave device

        Raises:
            FT4222DeviceError: on error

        """
        status = FT4222_SPI_Reset(self.handle);
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def spi_ResetTransaction(self, spiIdx):
        """Reset the SPI transaction

        Args:
            spiIdx (int): The index of the SPI transaction, which ranges from 0~3 depending on the mode of the chip.

        Raises:
            FT4222DeviceError: on error

        """
        status = FT4222_SPI_ResetTransaction(self.handle, spiIdx);
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def spi_SetDrivingStrength(self, clkStrength, ioStrength, ssoStrength):
        """Reset the SPI master or slave device.

        Args:
            clkStrength (ft4222.SPI.DrivingStrength): Driving strength clock pin (master only)
            ioStrength (ft4222.SPI.DrivingStrength): Driving strength io pin
            ssoStrength (ft4222.SPI.DrivingStrength): Driving strength sso pin (master only)

        Raises:
            FT4222DeviceError: on error

        """
        status = FT4222_SPI_SetDrivingStrength(self.handle, clkStrength, ioStrength, ssoStrength);
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def spiMaster_Init(self, mode, clock, cpol, cpha, ssoMap):
        """Initialize as an SPI master under all modes.

        Args:
            mode (ft4222.SPIMaster.Mode): SPI transmission lines / mode
            clock (ft4222.SPIMaster.Clock): Clock divider
            cpol (ft4222.SPIMaster.Cpol): Clock polarity
            cpha (ft4222.SPIMaster.Cpha): Clock phase
            ssoMap (ft4222.SPIMaster.SlaveSelect): Slave selection output pins

        Raises:
            FT4222DeviceError: on error

        """
        status = FT4222_SPIMaster_Init(self.handle, mode, clock, cpol, cpha, ssoMap);
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def spiMaster_SetLines(self, mode):
        """Switch the FT4222H SPI master to single, dual, or quad mode.

        This overrides the mode passed to FT4222_SPIMaster_init. This might be needed if a
        device accepts commands in single mode but data transfer is to use dual or quad mode.

        Args:
            mode (ft4222.SPIMaster.Mode): SPI transmission lines / mode

        Raises:
            FT4222DeviceError: on error

        """
        status = FT4222_SPIMaster_SetLines(self.handle, mode);
        if status != FT4222_OK:
            raise FT4222DeviceError, status

    def spiMaster_SingleRead(self, bytesToRead, isEndTransaction):
        """Read data from an SPI slave in single mode

        Args:
            bytesToRead (int): Number of bytes to read
            isEndTransaction (boolean): If True the slave select pin will be raised at the end

        Returns:
            (bytes): Bytes read from slave

        Raises:
            FT4222DeviceError: on error

        """
        cdef:
            array[uint8] buf = array('B', [])
            uint16 bytesRead
        resize(buf, bytesToRead)
        status = FT4222_SPIMaster_SingleRead(self.handle, buf.data.as_uchars, bytesToRead, &bytesRead, isEndTransaction)
        if status == FT4222_OK:
            resize(buf, bytesRead)
            return bytes(buf)
        raise FT4222DeviceError, status

    def spiMaster_SingleWrite(self, data, isEndTransaction):
        """Write data to an SPI slave in single mode

        Args:
            data (bytes, bytearray, int): Data to write to slave
            isEndTransaction (boolean): If True the slave select pin will be raised at the end

        Returns:
            (int): Bytes sent to slave

        Raises:
            FT4222DeviceError: on error

        """
        if isinstance(data, int):
            data = bytes([data])
        elif not isinstance(data, (bytes, bytearray)):
            raise TypeError("the data argument must be of type 'int', 'bytes' or 'bytearray'")
        cdef:
            uint16 bytesSent
            uint8* cdata = data
        status = FT4222_SPIMaster_SingleWrite(self.handle, cdata, len(data), &bytesSent, isEndTransaction);
        if status == FT4222_OK:
            return bytesSent
        raise FT4222DeviceError, status

    def spiMaster_SingleReadWrite(self, data, isEndTransaction):
        if isinstance(data, int):
            data = bytes([data])
        elif not isinstance(data, (bytes, bytearray)):
            raise TypeError("the data argument must be of type 'int', 'bytes' or 'bytearray'")
        cdef:
            uint16 sizeTransferred
            uint8* cdata = data
            array[uint8] buf = array('B', [])
        resize(buf, len(data))
        status = FT4222_SPIMaster_SingleReadWrite(self.handle, buf.data.as_uchars, cdata, len(data), &sizeTransferred, isEndTransaction);
        if status == FT4222_OK:
            resize(buf, sizeTransferred)
            return bytes(buf)
        raise FT4222DeviceError, status

    def spiMaster_MultiReadWrite(self, singleWrite, multiWrite, bytesToRead, sizeOfRead):
        if isinstance(singleWrite, int):
            data = bytes([singleWrite])
        elif not isinstance(singleWrite, (bytes, bytearray)):
            raise TypeError("the singleWrite argument must be of type 'int', 'bytes' or 'bytearray'")
        if isinstance(multiWrite, int):
            data = bytes([multiWrite])
        elif not isinstance(multiWrite, (bytes, bytearray)):
            raise TypeError("the multiWrite argument must be of type 'int', 'bytes' or 'bytearray'")
        write = singleWrite + multiWrite
        cdef:
            uint8* cdata = write
            array[uint8] buf = array('B', [])
            uint32 bytesRead
        resize(buf, bytesToRead)
        status = FT4222_SPIMaster_MultiReadWrite(self.handle, buf.data.as_uchars, cdata, len(singleWrite), len(multiWrite), bytesToRead, &bytesRead);
        if status == FT4222_OK:
            resize(buf, bytesRead)
            return bytes(buf)
        raise FT4222DeviceError, status

