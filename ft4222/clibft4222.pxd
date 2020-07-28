#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
# SPDX-License-Identifier: MIT
#
#cython: language_level=3

from __future__ import absolute_import
from libc.stdint cimport *
from .cftd2xx cimport *


cdef extern from "libft4222.h":
    ctypedef uint8_t  uint8
    ctypedef uint16_t uint16
    ctypedef uint32_t uint32
    ctypedef uint64_t uint64
    ctypedef int8_t   int8
    ctypedef int16_t  int16
    ctypedef int32_t  int32
    ctypedef int64_t  int64

    ctypedef enum FT4222_STATUS:
        FT4222_OK = 0
        FT4222_INVALID_HANDLE = 1
        FT4222_DEVICE_NOT_FOUND = 2
        FT4222_DEVICE_NOT_OPENED = 3
        FT4222_IO_ERROR = 4
        FT4222_INSUFFICIENT_RESOURCES = 5
        FT4222_INVALID_PARAMETER = 6
        FT4222_INVALID_BAUD_RATE = 7
        FT4222_DEVICE_NOT_OPENED_FOR_ERASE = 8
        FT4222_DEVICE_NOT_OPENED_FOR_WRITE = 9
        FT4222_FAILED_TO_WRITE_DEVICE = 10
        FT4222_EEPROM_READ_FAILED = 11
        FT4222_EEPROM_WRITE_FAILED = 12
        FT4222_EEPROM_ERASE_FAILED = 13
        FT4222_EEPROM_NOT_PRESENT = 14
        FT4222_EEPROM_NOT_PROGRAMMED = 15
        FT4222_INVALID_ARGS = 16
        FT4222_NOT_SUPPORTED = 17
        FT4222_OTHER_ERROR = 18
        FT4222_DEVICE_LIST_NOT_READY = 19

        FT4222_DEVICE_NOT_SUPPORTED = 1000        # FT_STATUS extending message
        FT4222_CLK_NOT_SUPPORTED = 1001
        FT4222_VENDER_CMD_NOT_SUPPORTED = 1002
        FT4222_IS_NOT_SPI_MODE = 1003
        FT4222_IS_NOT_I2C_MODE = 1004
        FT4222_IS_NOT_SPI_SINGLE_MODE = 1005
        FT4222_IS_NOT_SPI_MULTI_MODE = 1006
        FT4222_WRONG_I2C_ADDR = 1007
        FT4222_INVAILD_FUNCTION = 1008
        FT4222_INVALID_POINTER = 1009
        FT4222_EXCEEDED_MAX_TRANSFER_SIZE = 1010
        FT4222_FAILED_TO_READ_DEVICE = 1011
        FT4222_I2C_NOT_SUPPORTED_IN_THIS_MODE = 1012
        FT4222_GPIO_NOT_SUPPORTED_IN_THIS_MODE = 1013
        FT4222_GPIO_EXCEEDED_MAX_PORTNUM = 1014
        FT4222_GPIO_WRITE_NOT_SUPPORTED = 1015
        FT4222_GPIO_PULLUP_INVALID_IN_INPUTMODE = 1016
        FT4222_GPIO_PULLDOWN_INVALID_IN_INPUTMODE = 1017
        FT4222_GPIO_OPENDRAIN_INVALID_IN_OUTPUTMODE = 1018
        FT4222_INTERRUPT_NOT_SUPPORTED = 1019
        FT4222_GPIO_INPUT_NOT_SUPPORTED = 1020
        FT4222_EVENT_NOT_SUPPORTED = 1021
        FT4222_FUN_NOT_SUPPORT = 1022

    ctypedef enum FT4222_ClockRate:
        SYS_CLK_60 = 0
        SYS_CLK_24 = 1
        SYS_CLK_48 = 2
        SYS_CLK_80 = 3

    ctypedef enum I2C_MasterFlag:
        NONE = 0x80
        START = 0x02
        Repeated_START = 0x03  # Repeated_START will not send master code in HS mode
        STOP  = 0x04
        START_AND_STOP = 0x06  # START condition followed by SEND and STOP condition

    ctypedef enum GPIO_Trigger:
        GPIO_TRIGGER_RISING         = 0x01
        GPIO_TRIGGER_FALLING        = 0x02
        GPIO_TRIGGER_LEVEL_HIGH     = 0x04
        GPIO_TRIGGER_LEVEL_LOW      = 0X08

    ctypedef enum GPIO_Output:
        GPIO_OUTPUT_LOW = 0
        GPIO_OUTPUT_HIGH = 1

    ctypedef enum GPIO_Port:
        GPIO_PORT0  = 0
        GPIO_PORT1  = 1
        GPIO_PORT2  = 2
        GPIO_PORT3  = 3

    ctypedef enum GPIO_Dir:
        GPIO_OUTPUT = 0
        GPIO_INPUT  = 1

    ctypedef struct FT4222_Version:
        DWORD chipVersion
        DWORD dllVersion

    ctypedef enum FT4222_SPIMode:
        SPI_IO_NONE   = 0
        SPI_IO_SINGLE = 1
        SPI_IO_DUAL   = 2
        SPI_IO_QUAD   = 4

    ctypedef enum FT4222_SPIClock:
        CLK_NONE    = 0
        CLK_DIV_2   = 1   # 1/2   System Clock
        CLK_DIV_4   = 2   # 1/4   System Clock
        CLK_DIV_8   = 3   # 1/8   System Clock
        CLK_DIV_16  = 4   # 1/16  System Clock
        CLK_DIV_32  = 5   # 1/32  System Clock
        CLK_DIV_64  = 6   # 1/64  System Clock
        CLK_DIV_128 = 7   # 1/128 System Clock
        CLK_DIV_256 = 8   # 1/256 System Clock
        CLK_DIV_512 = 9   # 1/512 System Clock

    ctypedef enum FT4222_SPICPOL:
        CLK_IDLE_LOW  = 0
        CLK_IDLE_HIGH = 1

    ctypedef enum FT4222_SPICPHA:
        CLK_LEADING  = 0
        CLK_TRAILING = 1

    ctypedef enum SPI_DrivingStrength:
        DS_4MA  = 0
        DS_8MA  = 1
        DS_12MA = 2
        DS_16MA = 3

    ctypedef enum SPI_SlaveProtocol:
        SPI_SLAVE_WITH_PROTOCOL = 0
        SPI_SLAVE_NO_PROTOCOL   = 1    
        SPI_SLAVE_NO_ACK        = 2


    FT4222_STATUS FT4222_UnInitialize(FT_HANDLE ftHandle)
    FT4222_STATUS FT4222_SetClock(FT_HANDLE ftHandle, FT4222_ClockRate clk)
    FT4222_STATUS FT4222_GetClock(FT_HANDLE ftHandle, FT4222_ClockRate* clk)
    FT4222_STATUS FT4222_SetWakeUpInterrupt(FT_HANDLE ftHandle, BOOL enable)
    FT4222_STATUS FT4222_SetInterruptTrigger(FT_HANDLE ftHandle, GPIO_Trigger trigger)
    FT4222_STATUS FT4222_SetSuspendOut(FT_HANDLE ftHandle, BOOL enable)
    FT4222_STATUS FT4222_GetMaxTransferSize(FT_HANDLE ftHandle, uint16* pMaxSize)
    FT4222_STATUS FT4222_SetEventNotification(FT_HANDLE ftHandle, DWORD mask, PVOID param)
    FT4222_STATUS FT4222_GetVersion(FT_HANDLE ftHandle, FT4222_Version* pVersion)
    # FT4222 I2C Functions
    FT4222_STATUS FT4222_I2CMaster_Read(FT_HANDLE ftHandle, uint16 deviceAddress, uint8* buffer, uint16 bufferSize, uint16* sizeTransferred)
    FT4222_STATUS FT4222_I2CMaster_Write(FT_HANDLE ftHandle, uint16 deviceAddress, uint8* buffer, uint16 bufferSize, uint16* sizeTransferred)
    FT4222_STATUS FT4222_I2CMaster_Init(FT_HANDLE ftHandle, uint32 kbps)
    FT4222_STATUS FT4222_I2CMaster_ReadEx(FT_HANDLE ftHandle, uint16 deviceAddress, uint8 flag, uint8* buffer, uint16 bufferSize, uint16* sizeTransferred)
    FT4222_STATUS FT4222_I2CMaster_WriteEx(FT_HANDLE ftHandle, uint16 deviceAddress, uint8 flag, uint8* buffer, uint16 bufferSize, uint16* sizeTransferred)
    FT4222_STATUS FT4222_I2CMaster_Reset(FT_HANDLE ftHandle)
    FT4222_STATUS FT4222_I2CMaster_GetStatus(FT_HANDLE ftHandle, uint8 *controllerStatus)
    # FT4222 GPIO Functions
    FT4222_STATUS FT4222_GPIO_Init(FT_HANDLE ftHandle, GPIO_Dir gpioDir[4])
    FT4222_STATUS FT4222_GPIO_Read(FT_HANDLE ftHandle, GPIO_Port portNum, BOOL* value)
    FT4222_STATUS FT4222_GPIO_Write(FT_HANDLE ftHandle, GPIO_Port portNum, BOOL bValue)
    FT4222_STATUS FT4222_GPIO_SetInputTrigger(FT_HANDLE ftHandle, GPIO_Port portNum, GPIO_Trigger trigger)
    FT4222_STATUS FT4222_GPIO_GetTriggerStatus(FT_HANDLE ftHandle, GPIO_Port portNum, uint16* queueSize)
    FT4222_STATUS FT4222_GPIO_ReadTriggerQueue(FT_HANDLE ftHandle, GPIO_Port portNum, GPIO_Trigger* events, uint16 readSize, uint16* sizeofRead)
    # FT4222 SPI Functions
    FT4222_STATUS FT4222_SPI_Reset(FT_HANDLE ftHandle);
    FT4222_STATUS FT4222_SPI_ResetTransaction(FT_HANDLE ftHandle, uint8 spiIdx);
    FT4222_STATUS FT4222_SPI_SetDrivingStrength(FT_HANDLE ftHandle, SPI_DrivingStrength clkStrength, SPI_DrivingStrength ioStrength, SPI_DrivingStrength ssoStrength);
    FT4222_STATUS FT4222_SPIMaster_Init(FT_HANDLE ftHandle, FT4222_SPIMode  ioLine, FT4222_SPIClock clock, FT4222_SPICPOL  cpol, FT4222_SPICPHA  cpha, uint8 ssoMap);
    FT4222_STATUS FT4222_SPIMaster_SetLines(FT_HANDLE ftHandle, FT4222_SPIMode spiMode);
    FT4222_STATUS FT4222_SPIMaster_SingleRead(FT_HANDLE ftHandle, uint8* buffer, uint16 bufferSize, uint16* sizeOfRead, BOOL isEndTransaction);
    FT4222_STATUS FT4222_SPIMaster_SingleWrite(FT_HANDLE ftHandle, uint8* buffer, uint16 bufferSize, uint16* sizeTransferred, BOOL isEndTransaction);
    FT4222_STATUS FT4222_SPIMaster_SingleReadWrite(FT_HANDLE ftHandle, uint8* readBuffer, uint8* writeBuffer, uint16 bufferSize, uint16* sizeTransferred, BOOL isEndTransaction);
    FT4222_STATUS FT4222_SPIMaster_MultiReadWrite(FT_HANDLE ftHandle, uint8* readBuffer, uint8* writeBuffer, uint8 singleWriteBytes, uint16 multiWriteBytes, uint16 multiReadBytes, uint32* sizeOfRead);
    # FT4222 SPI Slave
    FT4222_STATUS FT4222_SPISlave_Init(FT_HANDLE ftHandle);
    FT4222_STATUS FT4222_SPISlave_InitEx(FT_HANDLE ftHandle, SPI_SlaveProtocol protocolOpt);
    FT4222_STATUS FT4222_SPISlave_SetMode(FT_HANDLE ftHandle, FT4222_SPICPOL  cpol, FT4222_SPICPHA  cpha);
    FT4222_STATUS FT4222_SPISlave_GetRxStatus(FT_HANDLE ftHandle, uint16* pRxSize);
    FT4222_STATUS FT4222_SPISlave_Read(FT_HANDLE ftHandle, uint8* buffer, uint16 bufferSize, uint16* sizeOfRead);
    FT4222_STATUS FT4222_SPISlave_Write(FT_HANDLE ftHandle, uint8* buffer, uint16 bufferSize, uint16* sizeTransferred);
    FT4222_STATUS FT4222_SPISlave_RxQuickResponse(FT_HANDLE ftHandle, BOOL enable);



