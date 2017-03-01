#   ________________     _________________    ________________
#  /                |   /                 |  |                 \
# |    __     __    |  |    ______________|  |    __________    |
# |   |  |   |  |   |  |   |                 |   |          |   |
# |___|  |___|  |   |  |   |______________   |   |          |   |
#  ___    ___   |   |  |                  |  |   |   _______|   |
# |___|  |   |  |   |  |_____________     |  |   |  |           |
#  ___   |___|  |   |                |    |  |   |  |__     ___/
# |___|   ___   |   |   _____________|    |  |   |     \    \
#  ___   |   |  |   |  |                  |  |   |      \    \
# |___|  |___|  |___|  |_________________/   |___|       \____\
#

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext



setup(
    name='pyFT4222',
    version='0.1',
    author='Martin Gysel',
    author_email='me@bearsh.org',
    url='http://msr.ch',
    description='python wrapper around libFT4222',
    packages=['ft4222', 'ft4222.I2CMaster', 'ft4222.GPIO'],
    ext_modules = [
        Extension("ft4222.ft4222", ["ft4222/ft4222.pyx"],
                  libraries=["ft4222"],
                  extra_compile_args=["-Ilinux"],
                  library_dirs=["linux/build-x86_64/"])
    ],
    cmdclass = {'build_ext': build_ext},
)
