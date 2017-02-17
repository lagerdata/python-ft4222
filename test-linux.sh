#!/usr/bin/env bash

unamem=$(uname -m)

case "$unamem" in
	x86_64) platform="x86_64" ;;
	i386|i686) platform="i386" ;;
	armv6*|armv7*) platform="arm-v6-hf" ;;
	*) echo "Libft4222 is not currently supported on '$unamem'."; exit 1 ;;
esac

LD_LIBRARY_PATH=linux/build-${platform}/. PYTHONPATH=. python3 test.py
