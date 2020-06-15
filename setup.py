#  _____ _____ _____
# |_    |   __| __  |
# |_| | |__   |    -|
# |_|_|_|_____|__|__|
# MSR Electronics GmbH
# SPDX-License-Identifier: MIT
#

from setuptools import setup
from setuptools.extension import Extension
from setuptools.command.build_py import build_py
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
        libdir = "linux/build-i386"
    libdirs = [libdir]
    rlibdirs = ['$ORIGIN/.']
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

class mybuild(build_py):
    def run(self):
        build_py.run(self)
        print("running mybuild")
        for package, src_dir, build_dir, filenames in self.data_files:
            if package == 'ft4222':
                for lib in libs_to_copy:
                    print("copying {} -> {}".format(libdir + "/" + lib, "ft4222/"+ lib))
                    shutil.copyfile(libdir + "/" + lib, build_dir + "/" + lib)
                break


extensions = [
    Extension("ft4222.ft4222", ["ft4222/ft4222.pyx"],
        libraries=libs,
        include_dirs=incdirs,
        library_dirs=libdirs,
        runtime_library_dirs=rlibdirs,
    ),
]

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name='ft4222',
    version='0.3',
    author='Bearsh',
    author_email='me@bearsh.org',
    url='https://msrelectronics.gitlab.io/python-ft4222',
    description='Python wrapper around libFT4222.',
    long_description=long_description,
    long_description_content_type="text/markdown",
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
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Topic :: Communications',
    ],
    keywords='ftdi ft4222',
    packages=['ft4222', 'ft4222.I2CMaster', 'ft4222.GPIO', 'ft4222.SPI', 'ft4222.SPIMaster'],
    ext_modules=cythonize(extensions),
    cmdclass={'build_py': mybuild},
)
