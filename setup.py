#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
# SPDX-License-Identifier: MIT
#

from setuptools import setup
from setuptools.extension import Extension
from setuptools.command.install import install
from Cython.Build import cythonize
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
    rlibdirs = ['./']
    libs_to_copy = ["libft4222.so"]
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
    rlibdirs = []
    libs_to_copy = [ft4222_dll, "ftd2xx.dll"]

class myinstall(install):
    def run(self):
        for lib in libs_to_copy:
            shutil.copyfile(libdir + "/" + lib, "ft4222/"+ lib)
        install.run(self)

extensions = [
    Extension("ft4222.ft4222", ["ft4222/ft4222.pyx"],
        libraries=libs,
        include_dirs=incdirs,
        library_dirs=libdirs,
        runtime_library_dirs=rlibdirs,
    ),
]

setup(
    name='ft4222',
    version='0.2',
    author='Bearsh',
    author_email='me@bearsh.org',
    url='https://msrelectronics.gitlab.io/python-ft4222',
    description='Python wrapper around libFT4222.',
    license='MIT',
    classifiers=[
        'Development Status :: 4 - Beta',
        'License :: OSI Approved :: MIT License',
        'License :: Other/Proprietary License',
        'Operating System :: Microsoft',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Cython',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Topic :: Communications',
    ],
    keywords='ftdi ft4222',
    packages=['ft4222', 'ft4222.I2CMaster', 'ft4222.GPIO', 'ft4222.SPI', 'ft4222.SPIMaster'],
    ext_modules=cythonize(extensions),
    cmdclass={'install': myinstall},
    package_data={'ft4222': libs_to_copy},
)
