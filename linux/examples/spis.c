/* FT4222H SPI Slave example.
 * 
 * Receive bytes from SPI Master, then process and return them.
 * 
 * Windows build instructions:
 *  1. Copy ftd2xx.h and 32-bit ftd2xx.lib from driver package.
 *  2. Build.
 *      MSVC:    cl spis.c LibFT4222.lib ftd2xx.lib
 *      MinGW:  gcc spis.c LibFT4222.lib ftd2xx.lib
 *
 * Linux instructions:
 *  1. Ensure libft4222.so is in the library search path (e.g. /usr/local/lib)
 *  2. gcc spis.c -lft4222 -Wl,-rpath,/usr/local/lib
 *  3. sudo ./a.out
 *
 * Mac instructions:
 *  1. Ensure libft4222.dylib is in the library search path (e.g. /usr/local/lib)
 *  2. gcc spis.c -lft4222 -Wl,-L/usr/local/lib
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

#define BYTES_EXPECTED 128 // Length of Master's message.

static uint8 rxBuffer[BYTES_EXPECTED];

#ifndef _WIN32
#include <sys/time.h>

static void Sleep(DWORD dwMilliseconds)
{
    struct timespec ts;

    ts.tv_sec = (time_t)dwMilliseconds / (time_t)1000;
    ts.tv_nsec = ((long int)dwMilliseconds % 1000L) * 1000000L;

    (void)nanosleep(&ts, NULL);
}
#endif // _WIN32


    
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



static int exercise4222(DWORD locationId)
{
    int                  success = 0;
    FT_STATUS            ftStatus;
    FT_HANDLE            ftHandle = (FT_HANDLE)NULL;
    FT4222_STATUS        ft4222Status;
    FT4222_Version       ft4222Version;
    uint16               bytesReceived = 0;
    uint16               bytesWritten = 0;
    int                  tries;
    const int            retryLimit = 321123456; // tune for your hardware
    int                  i;

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

    // Configure the FT4222 as SPI Slave.
    ft4222Status = FT4222_SPISlave_Init(ftHandle);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_SPISlave_Init failed (error %d)\n",
               (int)ft4222Status);
        goto exit;
    }

    // Wait for FT4222H to receive a MASTER_TRANSFER.
    for (tries = 0; tries < retryLimit; tries++)
    {
        uint16 bytesAvailable = 0;
        uint16 bytesRead = 0;

        ft4222Status = FT4222_SPISlave_GetRxStatus(ftHandle, 
                                                   &bytesAvailable);
        if (FT4222_OK != ft4222Status)
        {
            printf("FT4222_SPISlave_GetRxStatus failed (error %d)\n",
                   (int)ft4222Status);
            goto exit;
        }
        
        if (bytesAvailable == 0)
            continue;

        ft4222Status = FT4222_SPISlave_Read(ftHandle, 
                                            rxBuffer, 
                                            bytesAvailable, 
                                            &bytesRead);
        if (FT4222_OK != ft4222Status)
        {
            printf("FT4222_SPISlave_Read failed (error %d)\n",
                   (int)ft4222Status);
            goto exit;
        }
        
        bytesReceived += bytesRead;
        
        if (bytesReceived >= BYTES_EXPECTED)
            break; // Message complete
    }

    printf("\nReceived %u bytes from Master:\n", bytesReceived);
    hexdump(rxBuffer, BYTES_EXPECTED);
    
    // Convert message to upper-case, then write it to Master.
    for (i = 0; i < BYTES_EXPECTED; i++)
    {
        rxBuffer[i] = toupper(rxBuffer[i]);
    }

#ifdef VERIFY_CHECKSUM
{    
    uint16 checksum = 0x5a + 0x81 + BYTES_EXPECTED;
    
    for (i = 0; i < BYTES_EXPECTED; i++)
    {
        checksum += rxBuffer[i];
    }
    
    printf("Checksum: %04X\n", checksum);
}
#endif // VERIFY_CHECKSUM

    // On Windows 8.1, libft4222 seems to need this delay to make the
    // FT4222H actually send the following Slave_Write's data to the 
    // Master.  Sleep(0) is not sufficient.
    Sleep(1000);
    
    // Pass raw data to libFT4222, which will insert it into a
    // SLAVE_TRANSFER command (header, data, checksum) to be read
    // by the SPI Master.
    ft4222Status = FT4222_SPISlave_Write(ftHandle, 
                                         rxBuffer, 
                                         BYTES_EXPECTED,
                                         &bytesWritten);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_SPISlave_Write failed (error %d)\n",
               (int)ft4222Status);
        goto exit;
    }

    printf("FT4222_SPISlave_Write wrote %u (of %u) bytes.\n\n",
           bytesWritten,
           BYTES_EXPECTED);
    
    if (bytesWritten != BYTES_EXPECTED)
        goto exit;
        
    success = 1;

    // The FT4222H probably has our data now.  This delay keeps the 
    // FT4222H in SPI Slave mode long enough for the Master to read
    // the entire SLAVE_TRANSFER.
    Sleep(1000);

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
    int                       found = 0;
    
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
            found = 1;
            break;
        }
        
        if (devInfo[i].Type == FT_DEVICE_4222H_0)
        {
            printf("\nDevice %d is FT4222H in mode 0\n", i);
        }

        if (devInfo[i].Type == FT_DEVICE_4222H_1_2)
        {
            printf("\nDevice %d is FT4222H in mode 1 or 2\n", i);
        }
    }

    if (!found)
        printf("No mode-3 FT4222H device found.\n");

exit:
    free(devInfo);
    printf("Returning %d\n", retCode);
    return retCode;
}

int main(void)
{
    return testFT4222();
}

