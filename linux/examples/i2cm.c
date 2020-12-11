/* Read and write I2C Slave EEPROM.
 * Tested with 24LC01B (128 x 8-bits).
 *
 * Windows build instructions:
 *  1. Copy ftd2xx.h and 32-bit ftd2xx.lib from driver package.
 *  2. Build.
 *      MSVC:    cl i2cm.c LibFT4222.lib ftd2xx.lib
 *      MinGW:  gcc i2cm.c LibFT4222.lib ftd2xx.lib
 *
 * Linux instructions:
 *  1. Ensure libft4222.so is in the library search path (e.g. /usr/local/lib)
 *  2. gcc i2cm.c -lft4222 -Wl,-rpath,/usr/local/lib
 *  3. sudo ./a.out
 *
 * Mac instructions:
 *  1. Ensure libft4222.dylib is in the library search path (e.g. /usr/local/lib)
 *  2. gcc i2cm.c -lft4222 -Wl,-L/usr/local/lib
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

#define EEPROM_BYTES 128 // 24LC01B has 128 x 8 bits of storage
#define BYTES_PER_PAGE 8 // 24LC01B can be written in 8-byte pages


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


/* Sets given slave's current-address counter to specified value */
static FT4222_STATUS setWordAddress(FT_HANDLE     ftHandle,
                                    const uint16  slaveAddr,
                                    uint8         wordAddress)
{
    FT4222_STATUS        ft4222Status;
    uint16               bytesToWrite = 1;
    uint16               bytesWritten = 0;
    
    ft4222Status = FT4222_I2CMaster_Write(ftHandle,
                                          slaveAddr,
                                          &wordAddress,
                                          bytesToWrite,
                                          &bytesWritten);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_I2CMaster_Write 1 failed (error %d)\n",
               (int)ft4222Status);
        return ft4222Status;
    }

    if (bytesWritten != bytesToWrite)
    {
        printf("FT4222_I2CMaster_Write wrote %u of %u bytes.\n",
               bytesWritten,
               bytesToWrite);
    }

    return ft4222Status;
}


/* Call this after writing to the EEPROM.
 * This attempts to set the EEPROM's word address then
 * checks to see if the request was NACKed (which means 
 * the EEPROM is still busy).
 */
static FT4222_STATUS pollAddressAck(FT_HANDLE     ftHandle,
                                    const uint16  slaveAddr)
{
    FT4222_STATUS  ft4222Status = FT4222_OK;
    uint8          controllerStatus = 0;
    uint16         tries = 0;

    // 25 retries works for 24LC01B at 400 kHz.
    for (tries = 0; tries < 25; tries++)
    {
        // Try to set slave EEPROM's current word address counter.
        ft4222Status = setWordAddress(ftHandle,
                                      slaveAddr,
                                      0);
        if (FT4222_OK != ft4222Status)
        {
            return ft4222Status;
        }

        ft4222Status = FT4222_I2CMaster_GetStatus(ftHandle,
                                                  &controllerStatus);
        if (ft4222Status != FT4222_OK)
        {
            printf("FT4222_I2CMaster_GetStatus failed (%d).\n",
                   ft4222Status);
            return ft4222Status;
        }

#ifdef DEBUG_I2C_STATUS
        printf("%02X ", controllerStatus);
#endif // DEBUG_I2C_STATUS
        
        // Typically BUS_BUSY precedes ERROR state
        if (I2CM_BUS_BUSY(controllerStatus))
            continue;

        // I've observed IDLE both before and after the ERROR state.
        if (I2CM_IDLE(controllerStatus))
            continue;

        // Bus is not busy, and controller not idle, so check for error.
        if (!I2CM_ADDRESS_NACK(controllerStatus))
            break;
    }

#ifdef DEBUG_I2C_STATUS
    printf("%u tries, %02X\n", tries, controllerStatus);
#endif // DEBUG_I2C_STATUS

    return ft4222Status;
}


static int exercise4222(DWORD locationId)
{
    int                  success = 0;
    FT_STATUS            ftStatus;
    FT_HANDLE            ftHandle = (FT_HANDLE)NULL;
    FT4222_STATUS        ft4222Status;
    FT4222_Version       ft4222Version;
    const uint16         slaveAddr = 0x50;
    uint16               bytesToRead ;
    uint16               bytesRead = 0;
    uint16               bytesToWrite;
    uint16               bytesWritten = 0;
    char                *writeBuffer;
    uint8_t              pageBuffer[BYTES_PER_PAGE + 1];
    int                  page;
    

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

    // Configure the FT4222 as an I2C Master
    ft4222Status = FT4222_I2CMaster_Init(ftHandle, 400);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_I2CMaster_Init failed (error %d)!\n",
               ft4222Status);
        goto exit;
    }
    
    // Reset the I2CM registers to a known state.
    ft4222Status = FT4222_I2CMaster_Reset(ftHandle);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_I2CMaster_Reset failed (error %d)!\n",
               ft4222Status);
        goto exit;
    }

    // Before reading EEPROM, set buffer to known content
    memset(originalContent, '!', EEPROM_BYTES);

    // Reset slave EEPROM's current word address counter.
    ft4222Status = setWordAddress(ftHandle,
                                  slaveAddr,
                                  0);
    if (FT4222_OK != ft4222Status)
    {
        goto exit;
    }

    // Sequential read from slave EEPROM's current word address.
    bytesToRead = _countof(originalContent);
    ft4222Status = FT4222_I2CMaster_Read(ftHandle,
                                         slaveAddr,
                                         originalContent,
                                         bytesToRead,
                                         &bytesRead);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_I2CMaster_Read failed (error %d)\n",
               (int)ft4222Status);
        goto exit;
    }

    if (bytesRead != bytesToRead)
    {
        printf("FT4222_I2CMaster_Read read %u of %u bytes.\n",
               bytesRead,
               bytesToRead);
        goto exit;
    }
    
    if (0 != memcmp(originalContent, slogan1, EEPROM_BYTES))
        writeBuffer = slogan1;
    else
        writeBuffer = slogan2;

    printf("Writing \"%.20s...\"\n", writeBuffer);

    for (page = 0; page < EEPROM_BYTES/BYTES_PER_PAGE; page++)
    {
        // First byte to write is address (in EEPROM) of first byte in page.
        pageBuffer[0] = page * BYTES_PER_PAGE;
    
        // Copy a page's worth of data into the rest of pageBuffer.
        memcpy(&pageBuffer[1], 
               writeBuffer + page * BYTES_PER_PAGE, 
               BYTES_PER_PAGE);
    
        bytesToWrite = BYTES_PER_PAGE + 1;
        ft4222Status = FT4222_I2CMaster_Write(ftHandle,
                                              slaveAddr,
                                              pageBuffer,
                                              bytesToWrite,
                                              &bytesWritten);
        if (FT4222_OK != ft4222Status)
        {
            printf("FT4222_I2CMaster_Write 2 failed (error %d)\n",
                   (int)ft4222Status);
            goto exit;
        }

        if (bytesWritten != bytesToWrite)
        {
            printf("FT4222_I2CMaster_Write wrote %u of %u bytes.\n",
                   bytesWritten,
                   bytesToWrite);
            goto exit;
        }
        
        // Wait for EEPROM's write-cycle to complete.
        ft4222Status = pollAddressAck(ftHandle, slaveAddr);
        if (FT4222_OK != ft4222Status)
        {
            goto exit;
        }
    }

    memset(newContent, '!', EEPROM_BYTES);

    // Reset slave EEPROM's current word address counter.
    ft4222Status = setWordAddress(ftHandle,
                                  slaveAddr,
                                  0);
    if (FT4222_OK != ft4222Status)
    {
        goto exit;
    }

    // Sequential read from slave EEPROM's current word address.
    bytesToRead = _countof(newContent);
    ft4222Status = FT4222_I2CMaster_Read(ftHandle,
                                         slaveAddr,
                                         newContent,
                                         bytesToRead,
                                         &bytesRead);
    if (FT4222_OK != ft4222Status)
    {
        printf("FT4222_I2CMaster_Read failed (error %d)\n",
               (int)ft4222Status);
        goto exit;
    }

    if (bytesRead != bytesToRead)
    {
        printf("FT4222_I2CMaster_Read read %u of %u bytes.\n",
               bytesRead,
               bytesToRead);
        goto exit;
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
    int                       found4222 = 0;
    
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
        unsigned int devType = devInfo[i].Type;
        size_t       descLen;

        if (devType == FT_DEVICE_4222H_0)
        {
            // In mode 0, the FT4222H presents two interfaces: A and B.
            descLen = strlen(devInfo[i].Description);
            
            if ('A' == devInfo[i].Description[descLen - 1])
            {
                // Interface A may be configured as an I2C master.
                printf("\nDevice %d is interface A of mode-0 FT4222H:\n",
                       i);
                printf("  0x%08x  %s  %s\n", 
                       (unsigned int)devInfo[i].ID,
                       devInfo[i].SerialNumber,
                       devInfo[i].Description);
                (void)exercise4222(devInfo[i].LocId);
            }
            else
            {
                // Interface B of mode 0 is reserved for GPIO.
                printf("Skipping interface B of mode-0 FT4222H.\n");
            }
            
            found4222++;
        }
         
        if (devType == FT_DEVICE_4222H_1_2)
        {
            // In modes 1 and 2, the FT4222H presents four interfaces but
            // none is suitable for I2C.
            descLen = strlen(devInfo[i].Description);
            
            printf("Skipping interface %c of mode-1/2 FT4222H.\n",
                   devInfo[i].Description[descLen - 1]);
            
            found4222++;
        }
        
        if (devType == FT_DEVICE_4222H_3)
        {
            // In mode 3, the FT4222H presents a single interface.  
            // It may be configured as an I2C Master.
            printf("\nDevice %d is mode-3 FT4222H (single Master/Slave):\n",
                   i);
            printf("  0x%08x  %s  %s\n", 
                   (unsigned int)devInfo[i].ID,
                   devInfo[i].SerialNumber,
                   devInfo[i].Description);
            (void)exercise4222(devInfo[i].LocId);
            
            found4222++;
        }
    }

    if (!found4222)
        printf("No FT4222 found.\n");

exit:
    free(devInfo);
    return retCode;
}

int main (void)
{
    return testFT4222();
}

