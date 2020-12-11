/* Read and write SPI Slave EEPROM.
 * Tuned for AT93C46 (128 x 8-bits).
 * Windows build instructions:
 *  1. Copy ftd2xx.h and 32-bit ftd2xx.lib from driver package.
 *  2. Build.
 *      MSVC:    cl spim.c LibFT4222.lib ftd2xx.lib
 *      MinGW:  gcc spim.c LibFT4222.lib ftd2xx.lib
 * Linux instructions:
 *  1. Ensure libft4222.so is in the library search path (e.g. /usr/local/lib)
 *  2. gcc spim.c -lft4222 -Wl,-rpath,/usr/local/lib
 *  3. sudo ./a.out
 *
 *  Mac instructions:
 *  1. Ensure libft4222.dylib is in the library search path (e.g. /usr/local/lib)
 *  2. cc spim.c -lft4222 -Wl,-L/usr/local/lib
 *  3. ./a.out
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include "ftd2xx.h"
#include "libft4222.h"

#ifndef _countof
    #define _countof(a) (sizeof((a))/sizeof(*(a)))
#endif

#define EEPROM_BYTES 128 // AT93C46 has 128 x 8 bits of storage

// SPI Master can assert SS0O in single mode
// SS0O and SS1O in dual mode, and
// SS0O, SS1O, SS2O and SS3O in quad mode.
#define SLAVE_SELECT(x) (1 << (x))

static uint8 originalContent[EEPROM_BYTES];
static uint8 newContent[EEPROM_BYTES];
static char slogan1[EEPROM_BYTES + 1] = 
    "FTDI Chip strives to Make Design Easy with our modules, cables "
    "and integrated circuits for USB connectivity and display systems.";
static char slogan2[EEPROM_BYTES + 1] = 
    "FT4222H: Hi-Speed USB 2.0 QSPI/I2C device controller.  QFN32, "
    "1.8/2.5/3.3V IO, 128 bytes OTP.  Requires 12 MHz external crystal.";
    

    
static void hexdump(uint8 *address, uint16 length)
{
    char      buf[3*8 + 2 + 8 + 1];
    char      subString[4];
    int       f;
    int       offsetInLine = 0;
    char      printable;
    char      unprinted = 0;

    buf[0] = '\0';
    
    for (f = 0; f < length; f++)
    {
        offsetInLine = f % 8;
        
        if (offsetInLine == 0)
        {
            // New line.  Display previous line...
            printf("%s\n%p: ", buf, address + f);
            unprinted = 0;
            // ...and clear buffer ready for the new line.
            memset(buf, (int)' ', sizeof(buf));
            buf[sizeof(buf) - 1] = '\0';
        }
        
        sprintf(subString, "%02x ", (unsigned int)address[f]);        
        memcpy(&buf[offsetInLine * 3], subString, 3);
        
        if ( isprint((int)address[f]) )
            printable = (char)address[f];
        else
            printable = '.';
        sprintf(subString, "%c", printable);
        memcpy(&buf[3*8 + 2 + offsetInLine], subString, 1);        
        
        unprinted++; // Remember 
    }
    
    if (unprinted)
        printf("%s\n", buf);
        
    printf("\n");
}



/**
 * Enable write (and erase) operations.  AT93C46 disables them
 * at reset.
 *
 * @param ftHandle  Handle of open FT4222.
 *
 * @return 1 for success; 0 for failure.
 */
static int eeprom_enable_writes(FT_HANDLE ftHandle)
{
    FT4222_STATUS  ft4222Status;
    int            success = 1;
    uint16         bytesToTransceive;
    uint16         bytesTransceived;
    uint8          command[2] = {0x04, 0xFF};
    uint8          response[2] = {0, 0};

    // Start bit (1) + opcode (00) + 11xxxxxx, all padded with
    // leading zeroes to make a multiple of 8 bits.
    bytesToTransceive = 2;
    
    ft4222Status = FT4222_SPIMaster_SingleReadWrite(
                        ftHandle, 
                        response, 
                        command, 
                        bytesToTransceive, 
                        &bytesTransceived,
                        TRUE); // de-assert slave-select afterwards
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_SPIMaster_SingleReadWrite failed (error %d)!\n",
               ft4222Status);
        success = 0;
        goto exit;
    }

    if (bytesTransceived != bytesToTransceive)
    {
        printf("FT4222_SPIMaster_SingleReadWrite "
               "transceived %u bytes instead of %u.\n",
               bytesTransceived,
               bytesToTransceive);
        success = 0;
        goto exit;
    }
    
exit:    
    return success;
}



/**
 * Write a byte to a specified EEPROM address.
 *
 * @param ftHandle  Handle of open FT4222.
 * @param address   EEPROM-internal memory location (7 bits).
 * @param data      8-bit data to be stored in address.
 *
 * @return 1 for success, 0 for failure.
 */
static int eeprom_write(FT_HANDLE    ftHandle, 
                        const uint8  address, 
                        const uint8  data)
{
    FT4222_STATUS  ft4222Status;
    int            success = 1;
    int            i;
    int            j;
    int            writeComplete;
    uint16         bytesToTransceive;
    uint16         bytesTransceived;
    uint8          command[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};    
    uint8          response[10] = {42, 42, 42, 42, 42, 42, 42, 42, 42, 42};

    // Start bit (1) + opcode (01) + 7-bit address, all padded with
    // leading zeroes to make a multiple of 8 bits.
    command[0] = 0x02;
    command[1] = 0x80 | address;
    command[2] = data;
    
    bytesToTransceive = 3;
    
    ft4222Status = FT4222_SPIMaster_SingleReadWrite(
                        ftHandle, 
                        response, 
                        command, 
                        bytesToTransceive, 
                        &bytesTransceived,
                        TRUE); // de-assert slave-select afterwards
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_SPIMaster_SingleReadWrite failed (error %d)!\n",
               ft4222Status);
        success = 0;
        goto exit;
    }

    if (bytesTransceived != bytesToTransceive)
    {
        printf("FT4222_SPIMaster_SingleReadWrite "
               "transceived %u bytes instead of %u.\n",
               bytesTransceived,
               bytesToTransceive);
        success = 0;
        goto exit;
    }
    
    // Previous transceive de-asserted slave-select; the following transceive
    // asserts it and keeps it asserted.  Together this creates a short pulse
    // (unasserted) which tells the AT93C46 to signal when the write is 
    // complete.  It does this by raising MISO, so we poll for this by
    // transceiving chunks of 10 dummy bytes until we receive a non-zero bit.
    writeComplete = 0;
    bytesToTransceive = 10;
    memset(command, 0, 10); // All zero, so EEPROM won't see a start-bit
    for (i = 0; !writeComplete && i < 1000; i++)
    {
        ft4222Status = FT4222_SPIMaster_SingleReadWrite(
                            ftHandle, 
                            response, 
                            command, 
                            bytesToTransceive, 
                            &bytesTransceived,
                            FALSE); // keep slave-select asserted
        if (FT4222_OK != ft4222Status)
        {
            printf("FT4222_SPIMaster_SingleReadWrite failed (error %d)!\n",
                   ft4222Status);
            success = 0;
            break;
        }

        if (bytesTransceived != bytesToTransceive)
        {
            printf("FT4222_SPIMaster_SingleReadWrite "
                   "transceived %u bytes instead of %u.\n",
                   bytesTransceived,
                   bytesToTransceive);
            success = 0;
            break;
        }
        
        for (j = 0; j < 10; j++)
        {
            if (response[j] != 0)
            {
                writeComplete = 1;
                break;
            }
        }
    }

    if (!writeComplete)
    {
        printf("AT93C46 did not confirm that the write completed.\n");
        success = 0;
    }

    // Extra dummy write to de-assert slave-select.
    (void)FT4222_SPIMaster_SingleReadWrite(
                        ftHandle, 
                        response, 
                        command, 
                        1, 
                        &bytesTransceived,
                        TRUE); // de-assert slave-select afterwards.

exit:
    return success;
}



/**
 * Read a byte from the specified EEPROM address.
 *
 * @param ftHandle  Handle of open FT4222.
 * @param address   EEPROM-internal memory location (7 bits).
 * @param data      Receives copy of 8-bit data stored at address.
 *
 * @return 1 for success, 0 for failure.
 */
static int eeprom_read(FT_HANDLE    ftHandle, 
                       const uint8  address, 
                       uint8       *data)
{
    FT4222_STATUS  ft4222Status;
    int            success = 1;
    uint16         bytesToTransceive;
    uint16         bytesTransceived;
    uint8          command[4] = {0x03, 0x00, 0x00, 0x00};
    uint8          response[4] = {42, 42, 42, 42};
    uint8          result = 0;

    // Start bit (1) + opcode (10) + address to read, all padded with
    // leading zeroes to make a multiple of 8 bits.
    command[1] |= address;    
    
    bytesToTransceive = 4;
    
    ft4222Status = FT4222_SPIMaster_SingleReadWrite(
                        ftHandle, 
                        response, 
                        command, 
                        bytesToTransceive, 
                        &bytesTransceived,
                        TRUE); // de-assert slave-select afterwards
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_SPIMaster_SingleReadWrite failed (error %d)!\n",
               ft4222Status);
        success = 0;
        goto exit;
    }

    if (bytesTransceived != bytesToTransceive)
    {
        printf("FT4222_SPIMaster_SingleReadWrite "
               "transceived %u bytes instead of %u.\n",
               bytesTransceived,
               bytesToTransceive);
        success = 0;
        goto exit;
    }
    
    // Value read from EEPROM is in bits 0 to 6 of byte 2, plus
    // bit 7 of byte 3
    result = (response[2] << 1) & 0xFE;  // byte 2, bits 0 to 6
    result |= (response[3] >> 7) & 0x01; // byte 3, bit 1
    
    *data = result;

exit:
    return success;
}



static int exercise4222(DWORD locationId)
{
    int                  success = 0;
    FT_STATUS            ftStatus;
    FT_HANDLE            ftHandle = (FT_HANDLE)NULL;
    FT4222_STATUS        ft4222Status;
    FT4222_Version       ft4222Version;
    uint8                address;
    char                *writeBuffer;

    ftStatus = FT_OpenEx((PVOID)(uintptr_t)locationId, 
                         FT_OPEN_BY_LOCATION, 
                         &ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("FT_OpenEx failed (error %d)\n", 
               (int)ftStatus);
        goto exit;
    }
    
    ft4222Status = FT4222_GetVersion(ftHandle,
                                     &ft4222Version);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_GetVersion failed (error %d)\n",
               (int)ft4222Status);
        goto exit;
    }
    
    printf("Chip version: %08X, LibFT4222 version: %08X\n",
           (unsigned int)ft4222Version.chipVersion,
           (unsigned int)ft4222Version.dllVersion);

    // Configure the FT4222 as an SPI Master.
    ft4222Status = FT4222_SPIMaster_Init(
                        ftHandle, 
                        SPI_IO_SINGLE, // 1 channel
                        CLK_DIV_32, // 60 MHz / 32 == 1.875 MHz
                        CLK_IDLE_LOW, // clock idles at logic 0
                        CLK_LEADING, // data captured on rising edge
                        SLAVE_SELECT(0)); // Use SS0O for slave-select
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_SPIMaster_Init failed (error %d)\n",
               (int)ft4222Status);
        goto exit;
    }

    ft4222Status = FT4222_SPI_SetDrivingStrength(ftHandle,
                                                 DS_8MA,
                                                 DS_8MA,
                                                 DS_8MA);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_SPI_SetDrivingStrength failed (error %d)\n",
               (int)ft4222Status);
        goto exit;
    }

    // First read original content
    memset(originalContent, '!', EEPROM_BYTES);

    for (address = 0; address < EEPROM_BYTES; address++)
    {
        if (!eeprom_read(ftHandle, address, &originalContent[address]))
        {
            printf("Failed to read address %02X.\n",
                   (unsigned int)address);
            // Failed, but keep trying subsequent addresses.
        }
    }
    
    if (0 != memcmp(originalContent, slogan1, EEPROM_BYTES))
        writeBuffer = slogan1;
    else
        writeBuffer = slogan2;

    if (!eeprom_enable_writes(ftHandle))
    {
        printf("Failed to enable EEPROM writes.\n");
        goto exit;
    }
    
    for (address = 0; address < EEPROM_BYTES; address++)
    {
        if (!eeprom_write(ftHandle, address, writeBuffer[address]))
        {
            printf("Failed to write to address %02X.\n",
                   (unsigned int)address);
            // Failed, but keep trying subsequent addresses.
        }
    }

    memset(newContent, '!', EEPROM_BYTES);

    for (address = 0; address < EEPROM_BYTES; address++)
    {
        if (!eeprom_read(ftHandle, address, &newContent[address]))
        {
            printf("Failed to read address %02X.\n",
                   (unsigned int)address);
            // Failed, but keep trying subsequent addresses.
        }
    }

    printf("\nOriginal content of EEPROM:\n");
    hexdump(originalContent, EEPROM_BYTES);
    
    printf("\nNew content of EEPROM:\n");
    hexdump(newContent, EEPROM_BYTES);

    success = 1;

exit:
    if (ftHandle != (FT_HANDLE)NULL)
    {
        (void)FT4222_UnInitialize(ftHandle);
        (void)FT_Close(ftHandle);
    }

    return success;
}


static int testFT4222(void)
{
    FT_STATUS                 ftStatus;
    FT_DEVICE_LIST_INFO_NODE *devInfo = NULL;
    DWORD                     numDevs = 0;
    int                       i;
    int                       retCode = 0;
    
    ftStatus = FT_CreateDeviceInfoList(&numDevs);
    if (ftStatus != FT_OK) 
    {
        printf("FT_CreateDeviceInfoList failed (error code %d)\n", 
               (int)ftStatus);
        retCode = -10;
        goto exit;
    }
    
    if (numDevs == 0)
    {
        printf("No devices connected.\n");
        retCode = -20;
        goto exit;
    }

    /* Allocate storage */
    devInfo = calloc((size_t)numDevs,
                     sizeof(FT_DEVICE_LIST_INFO_NODE));
    if (devInfo == NULL)
    {
        printf("Allocation failure.\n");
        retCode = -30;
        goto exit;
    }
    
    /* Populate the list of info nodes */
    ftStatus = FT_GetDeviceInfoList(devInfo, &numDevs);
    if (ftStatus != FT_OK)
    {
        printf("FT_GetDeviceInfoList failed (error code %d)\n",
               (int)ftStatus);
        retCode = -40;
        goto exit;
    }

    for (i = 0; i < (int)numDevs; i++) 
    {
        if (devInfo[i].Type == FT_DEVICE_4222H_3)
        {
            printf("\nDevice %d is FT4222H in mode 3 (single Master or Slave):\n",i);
            printf("  0x%08x  %s  %s\n", 
                   (unsigned int)devInfo[i].ID,
                   devInfo[i].SerialNumber,
                   devInfo[i].Description);
            (void)exercise4222(devInfo[i].LocId);
            break;
        }
    }

exit:
    free(devInfo);
    return retCode;
}

int main(void)
{
    return testFT4222();
}

