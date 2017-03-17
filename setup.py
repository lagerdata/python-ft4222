#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
#

from distutils.core import setup
from distutils.extension import Extension
from distutils.command.install import install
from Cython.Distutils import build_ext
from sys import platform as os_name
import platform
import shutil

is_64_bit = platform.architecture()[0] == '64bit'
if os_name.startswith("linux"):
    libs = ["ft4222"]
    incdirs = ["linux"]
    if is_64_bit:
        libdir = "linux/build-x86_64"
    else:
        libdir = "linux/build-pentium"
    libdirs = [libdir]
    libs_to_copy = []
else:
    libs = ["LibFT4222", "ftd2xx"]
    incdirs = ["win"]
    if is_64_bit:
        libdir = "win/amd64"
        ft4222_dll = "LibFT4222-64.dll"
    else:
        libdir = "win/i386"
        ft4222_dll = "LibFT4222.dll"
    libdirs = [libdir]
    libs_to_copy = [ft4222_dll, "ftd2xx.dll"]

class myinstall(install):
    def run(self):
        for lib in libs_to_copy:
            shutil.copyfile(libdir + "/" + lib, "ft4222/"+ lib)
        install.run(self)

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
    cmdclass = {'install': myinstall, 'build_ext': build_ext},
    package_data= {'ft4222': libs_to_copy},
)
