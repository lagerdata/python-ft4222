.. ft4222 documentation master file, created by
   sphinx-quickstart on Wed Mar  1 13:03:33 2017.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

ft4222's Documentation
======================

Python bindings to LibFT4222 (`user guide <http://www.ftdichip.com/Support/Documents/AppNotes/AN_329_User_Guide_for_LibFT4222.pdf>`_).

FT4222H
-------

The FT4222H is a High/Full Speed USB2.0-to-Quad SPI/I2C device controller.

This device contains both SPI and I2C configurable interfaces. The SPI interface can be configured as master mode with single, dual and quad bits data width transfer, or slave mode with single bit data width transfer. The I2C interface can be configured in master or slave mode.

`<http://www.ftdichip.com/Products/ICs/FT4222H.html>`_

.. toctree::
   :maxdepth: 2
   :caption: Contents:


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

API
===

.. automodule:: ft4222
    :members:

.. autoclass:: FT4222
    :members:

.. automodule:: ft4222.I2CMaster
    :members:

.. automodule:: ft4222.GPIO
    :members:

.. automodule:: ft4222.SPI
    :members:

.. automodule:: ft4222.SPIMaster
    :members:
