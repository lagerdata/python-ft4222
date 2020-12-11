# Install libft4222 and headers into /usr/local, so run using sudo!

if [ "$(id -u)" != "0" ] ; then
	echo "You must run this script with sudo."
	exit 1
fi

unamem=$(uname -m)

case "$unamem" in
	x86_64) platform="x86_64"
	;;
	i386 | i686) platform="i386"
	;;
	armv6*) platform="arm-v6-hf"
	;;
	armv7* ) platform="arm-v7-hf"
	;;
	armv8* | aarch64 ) platform="arm-v8"
	;;
	*) echo "Libft4222 is not currently supported on '$unamem'."
	exit 1
	;;
esac

# Inside libft4222.tgz are release/32 and release/64 directories.
pathToLib=$(ls build-$platform/libft4222.so.*)
# echo "Found $pathToLib"
Lib=$(basename $pathToLib)
echo "Copying $pathToLib to /usr/local/lib"
yes | cp "$pathToLib" /usr/local/lib

# Remove any existing symlink for libft4222
rm -f /usr/local/lib/libft4222.so
ln -sf /usr/local/lib/$Lib /usr/local/lib/libft4222.so
ls -l /usr/local/lib/libft4222*

echo "Copying headers to /usr/local/include"
cp libft4222.h /usr/local/include
cp ftd2xx.h /usr/local/include
cp WinTypes.h /usr/local/include
ls -l /usr/local/include/*.h

