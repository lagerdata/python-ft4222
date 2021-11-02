import enum
from typing import Any, ClassVar, List, Optional, TypedDict, Union, overload

from ft4222 import GPIO, SPI, I2CMaster, SPIMaster

class FT2XXDeviceError(Exception):
    def __init__(self, msgnum: int) -> None: ...

class FT4222DeviceError(FT2XXDeviceError):
    def __init__(self, msgnum: int) -> None: ...

class SysClock(enum.IntEnum):
    CLK_24: int
    CLK_48: int
    CLK_60: int
    CLK_80: int

class DeviceDetail(TypedDict):
    index: int
    flags: int
    type: int
    id: int
    location: int
    serial: bytes
    description: bytes
    handle: int

def createDeviceInfoList() -> int: ...
def getDeviceInfoDetail(devnum: int, update: bool) -> DeviceDetail: ...
def openBySerial(serial: Union[str, bytes]) -> FT4222: ...
def openByDescription(desc: Union[str, bytes]) -> FT4222: ...
def openByLocation(locId: int) -> FT4222: ...

class FT4222:
    def __init__(self, handle: int, update: bool) -> None: ...
    @property
    def chipRevision(self) -> str: ...
    @property
    def chipVersion(self) -> int: ...
    @property
    def libVersion(self) -> int: ...
    def setTimeouts(self, read_timeout: int, write_timeout: int) -> None: ...
    def close(self) -> None: ...
    def setClock(self, clk: SysClock) -> None: ...
    def getClock(self) -> SysClock: ...
    def setSuspendOut(self, enable: bool) -> None: ...
    def setWakeUpInterrut(self, enable: bool) -> None: ...
    def vendorCmdGet(self, req: Union[str, bytes], bytesToRead: int) -> bytes: ...
    def vendorCmdSet(
        self, req: Union[str, bytes], data: Union[int, bytes, bytearray]
    ) -> None: ...
    def gpio_Init(
        self,
        *args: Any,
        gpio0: GPIO.Dir,
        gpio1: GPIO.Dir,
        gpio2: GPIO.Dir,
        gpio3: GPIO.Dir
    ) -> None: ...
    def gpio_Read(self, portNum: GPIO.Port) -> bool: ...
    def gpio_Write(self, portNum: GPIO.Port, value: bool) -> None: ...
    def gpio_SetInputTrigger(
        self, portNum: GPIO.Port, trigger: GPIO.Trigger
    ) -> None: ...
    def gpio_GetTriggerStatus(self, portNum: GPIO.Port) -> GPIO.Trigger: ...
    def gpio_ReadTriggerQueue(
        self, portNum: GPIO.Port, readsize: Optional[int]
    ) -> List[GPIO.Trigger]: ...
    def i2cMaster_Init(self, kbps: int) -> None: ...
    def i2cMaster_Read(self, addr: int, bytesToRead: int) -> bytes: ...
    def i2cMaster_ReadEx(self, addr: int, flag: int, bytesToRead: int) -> bytes: ...
    def i2cMaster_Write(self, addr: int, data: Union[int, bytes, bytearray]) -> int: ...
    def i2cMaster_WriteEx(
        self, addr: int, flag: int, data: Union[int, bytes, bytearray]
    ) -> int: ...
    def i2cMaster_Reset(self) -> None: ...
    def i2cMaster_GetStatus(self) -> I2CMaster.ControllerStatus: ...
    def spi_Reset(self) -> None: ...
    def spi_ResetTransaction(self, spiIdx: int) -> None: ...
    def spi_SetDrivingStrength(
        self,
        clkStrength: SPI.DrivingStrength,
        ioStrength: SPI.DrivingStrength,
        ssoStrength: SPI.DrivingStrength,
    ) -> None: ...
    def spiMaster_Init(
        self,
        mode: SPIMaster.Mode,
        clock: SPIMaster.Clock,
        cpol: SPI.Cpol,
        cpha: SPI.Cpha,
        ssoMap: SPIMaster.SlaveSelect,
    ) -> None: ...
    def spiMaster_SetLines(self, mode: SPIMaster.Mode) -> None: ...
    def spiMaster_SingleRead(
        self, bytesToRead: int, isEndTransaction: bool
    ) -> bytes: ...
    def spiMaster_SingleWrite(
        self, data: Union[int, bytes, bytearray], isEndTransaction: bool
    ) -> None: ...
    def spiMaster_SingleReadWrite(
        self, data: Union[int, bytes, bytearray], isEndTransaction: bool
    ) -> bytes: ...
    def spiMaster_MultiReadWrite(
        self,
        singleWrite: Union[int, bytes, bytearray],
        multiWrite: Union[int, bytes, bytearray],
        bytesToRead: int,
    ) -> bytes: ...
    def spiMaster_EndTransaction(self) -> None: ...
    def spiSlave_Init(self) -> None: ...
    def spiSlave_InitEx(self, mode: SPIMaster.Mode) -> None: ...
    def spiSlave_Read(self, bytesToRead: int) -> bytes: ...
    def spiSlave_SetMode(self, cpol: SPI.Cpol, cpha: SPI.Cpha) -> None: ...
    def spiSlave_GetRxStatus(self) -> int: ...
    def spiSlave_Write(self, data: Union[int, bytes, bytearray]) -> int: ...
