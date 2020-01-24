#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
# SPDX-License-Identifier: MIT
#
#cython: language_level=3

cdef extern from "ftd2xx.h":
    ctypedef unsigned int DWORD
    ctypedef unsigned int ULONG
    ctypedef unsigned short USHORT
    ctypedef unsigned short SHORT
    ctypedef unsigned char UCHAR
    ctypedef unsigned short WORD
    ctypedef unsigned char BYTE
    ctypedef BYTE* LPBYTE
    ctypedef unsigned int BOOL
    ctypedef unsigned char BOOLEAN
    ctypedef unsigned char CHAR
    ctypedef BOOL* LPBOOL
    ctypedef UCHAR* PUCHAR
    ctypedef const char* LPCSTR
    ctypedef char* PCHAR
    ctypedef void* PVOID
    ctypedef void* HANDLE
    ctypedef unsigned int LONG
    ctypedef int INT
    ctypedef unsigned int UINT
    ctypedef char* LPSTR
    ctypedef char* LPTSTR
    ctypedef const char* LPCTSTR
    ctypedef DWORD* LPDWORD
    ctypedef WORD* LPWORD
    ctypedef ULONG* PULONG
    ctypedef LONG* LPLONG
    ctypedef PVOID LPVOID
    ctypedef void VOID
    ctypedef unsigned long long int ULONGLONG

    cdef enum:
        FT_OK = 0
        FT_INVALID_HANDLE = 1
        FT_DEVICE_NOT_FOUND = 2
        FT_DEVICE_NOT_OPENED = 3
        FT_IO_ERROR = 4
        FT_INSUFFICIENT_RESOURCES = 5
        FT_INVALID_PARAMETER = 6
        FT_INVALID_BAUD_RATE = 7

        FT_DEVICE_NOT_OPENED_FOR_ERASE = 8
        FT_DEVICE_NOT_OPENED_FOR_WRITE = 9
        FT_FAILED_TO_WRITE_DEVICE = 10
        FT_EEPROM_READ_FAILED = 11
        FT_EEPROM_WRITE_FAILED = 12
        FT_EEPROM_ERASE_FAILED = 13
        FT_EEPROM_NOT_PRESENT = 14
        FT_EEPROM_NOT_PROGRAMMED = 15
        FT_INVALID_ARGS = 16
        FT_NOT_SUPPORTED = 17
        FT_OTHER_ERROR = 18
        FT_DEVICE_LIST_NOT_READY = 19

    cdef enum:
        FT_OPEN_BY_SERIAL_NUMBER = 1
        FT_OPEN_BY_DESCRIPTION = 2
        FT_OPEN_BY_LOCATION = 4

    ctypedef PVOID FT_HANDLE
    ctypedef ULONG FT_STATUS

    FT_STATUS FT_CreateDeviceInfoList(LPDWORD lpdwNumDevs)

    FT_STATUS FT_GetDeviceInfoDetail(DWORD dwIndex, LPDWORD lpdwFlags,
        LPDWORD lpdwType, LPDWORD lpdwID, LPDWORD lpdwLocId, LPVOID lpSerialNumber,
        LPVOID lpDescription, FT_HANDLE *pftHandle)

    FT_STATUS FT_OpenEx(PVOID pArg1, DWORD Flags, FT_HANDLE *pHandle)
    FT_STATUS FT_Close(FT_HANDLE ftHandle)

    FT_STATUS FT_Write(FT_HANDLE ftHandle, LPVOID lpBuffer, DWORD dwBytesToWrite, LPDWORD lpBytesWritten);
    FT_STATUS FT_VendorCmdGet(FT_HANDLE ftHandle, UCHAR Request, UCHAR *Buf, USHORT Len);
    FT_STATUS FT_VendorCmdSet(FT_HANDLE ftHandle, UCHAR Request, UCHAR *Buf, USHORT Len);
