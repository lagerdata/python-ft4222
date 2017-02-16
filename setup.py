from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    ext_modules = cythonize([
        Extension("ft4222", ["ft4222.pyx"],
                  libraries=["ft4222"])
    ])
)
