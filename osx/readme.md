# OSX

change library names and id:

```bash
install_name_tool -id @loader_path/libft4222.dylib libft4222.dylib
install_name_tool -change libftd2xx.dylib @loader_path/libftd2xx.dylib libft4222.dylib
install_name_tool -change /usr/local/opt/boost/lib/libboost_system.dylib @loader_path/libboost_system.dylib libft4222.dylib
```
