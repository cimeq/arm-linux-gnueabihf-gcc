# arm-linux-gnueabihf-gcc
Repo holder for the toolchain: arm-linux-gnueabihf-gcc
### Add toolchain
To use GCC compiler, add this to your main CMakeLists.txt before the **Project** directive. This will download the selected toolchain file.
If the compiler is not supported, an error will be reported. To adde new compiler, the ficle gccDownloaderHelper.cmake need to be modified.

```cmake
#enable the toolcahin file if not in unit test mode
if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "UTest")
#Get toolchain file
CPMAddPackage(
		NAME arm-linux-gnueabihf-gcc
		GIT_REPOSITORY https://github.com/cimeq/arm-linux-gnueabihf-gcc.git
		GIT_TAG master
		SOURCE_DIR ${CMAKE_SOURCE_DIR}/cmake/arm-linux-gnueabihf-gcc
)
#Append the new cmake helper folder
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/arm-linux-gnueabihf-gcc")
#Use a specific compiler version here
	set(TOOLCHAIN_PATH "..." CACHE STRING "Path to the toolchain" FORCE)
	set(RASPBERRY_VERSION "..." CACHE STRING "Version of the raspberry pi" FORCE)
	set(RASPBIAN_ROOTFS "..." CACHE STRING "Path to the sysroot of the pi" FORCE)
    
	if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
		set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/arm-linux-gnueabihf-gcc/arm-linux-gnueabihf-gcc.cmake" CACHE UNINITIALIZED "toolchain file")
	endif()
endif()
```
  
example:
- `TOOLCHAIN_PATH==/opt/cross-pi-gcc-10.1.0-2` 
- `RASPBERRY_VERSION==4`
- `RASPBIAN_ROOTFS==$ENV{HOME}/raspberry/sysroot`

### Version supported
