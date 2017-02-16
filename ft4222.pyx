
from cftd2xx cimport *
from clibft4222 cimport *

def createDeviceInfoList():
    """Create the internal device info list and return number of entries"""
    cdef DWORD nb
    st = FT_CreateDeviceInfoList(&nb)
    if st == FT_OK:
        return nb
    return None
