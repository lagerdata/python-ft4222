#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
#

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from sys import platform as os_name
import platform

is_64_bit = platform.architecture()[0] == '64bit'


if os_name.startswith("linux"):
    libs = ["ft4222"]
    incdirs = ["linux"]
    if is_64_bit:
        libdirs = ["linux/build-x86_64"]
    else:
        libdirs = ["linux/build-pentium"]
else:
    libs = ["LibFT4222", "ftd2xx"]
    incdirs = ["win"]
    if is_64_bit:
        libdirs = ["win/amd64"]
    else:
        libdirs = ["win/i386"]


setup(
    name='ft4222',
    version='0.1',
    author='Martin Gysel',
    author_email='me@bearsh.org',
    url='http://msr.ch',
    description='python wrapper around libFT4222',
    packages=['ft4222', 'ft4222.I2CMaster', 'ft4222.GPIO'],
    ext_modules = [
        Extension("ft4222.ft4222", ["ft4222/ft4222.pyx"],
                  libraries=libs,
                  include_dirs=incdirs,
                  library_dirs=libdirs,
                  extra_compile_args=["-O3"],
                  )
    ],
    cmdclass = {'build_ext': build_ext},
)
