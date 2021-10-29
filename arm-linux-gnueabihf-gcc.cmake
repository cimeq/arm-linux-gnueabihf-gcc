# Based on:
# https://gitlab.linphone.org/BC/public/linphone-cmake-builder/blob/master/toolchains/toolchain-raspberry.cmake
# Updated version:
# https://github.com/Pro/raspi-toolchain/blob/master/Toolchain-rpi.cmake

if("${RASPBERRY_VERSION}" STREQUAL "")
	set(RASPBERRY_VERSION 1)
else()
	if(${RASPBERRY_VERSION} VERSION_GREATER 4)
		set(RASPBERRY_VERSION 4)
	else()
		set(RASPBERRY_VERSION ${RASPBERRY_VERSION})
	endif()
endif()

# RASPBIAN_ROOTFS should point to the local directory which contains all the libraries and includes from the target raspi.
# Get them with:
# rsync -vR --progress -rl --delete-after --safe-links pi@192.168.1.PI:/{lib,usr,opt/vc/lib} $HOME/rpi/rootfs
# Then RASPBIAN_ROOTFS=$HOME/rpi/rootfs
# set(RASPBIAN_ROOTFS "$ENV{HOME}/raspberry/sysroot")

if(NOT RASPBIAN_ROOTFS)
	if(NOT "${PROJECT_NAME}" STREQUAL "CMAKE_TRY_COMPILE")
	    message(FATAL_ERROR "Define the RASPBIAN_ROOTFS environment variable to point to the raspbian rootfs.")
    endif()
else()
	set(SYSROOT_PATH "${RASPBIAN_ROOTFS}")
endif()
set(TOOLCHAIN_HOST "${TOOLCHAIN_PATH}/bin/arm-linux-gnueabihf")

message(STATUS "Using sysroot path: ${SYSROOT_PATH}")

set(TOOLCHAIN_CC "${TOOLCHAIN_HOST}-gcc")
set(TOOLCHAIN_CXX "${TOOLCHAIN_HOST}-g++")
set(TOOLCHAIN_LD "${TOOLCHAIN_HOST}-ld")
#set(TOOLCHAIN_LD "${TOOLCHAIN_CXX}")
set(TOOLCHAIN_AR "${TOOLCHAIN_HOST}-ar")
set(TOOLCHAIN_RANLIB "${TOOLCHAIN_HOST}-ranlib")
set(TOOLCHAIN_STRIP "${TOOLCHAIN_HOST}-strip")
set(TOOLCHAIN_NM "${TOOLCHAIN_HOST}-nm")

set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSROOT "${SYSROOT_PATH}")

# Define name of the target system
set(CMAKE_SYSTEM_NAME "Linux")
if(RASPBERRY_VERSION VERSION_GREATER 1)
	set(CMAKE_SYSTEM_PROCESSOR "armv7")
else()
	set(CMAKE_SYSTEM_PROCESSOR "arm")
endif()

# Define the compiler
set(CMAKE_C_COMPILER ${TOOLCHAIN_CC})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_CXX})


# List of library dirs where LD has to look. Pass them directly through gcc. LD_LIBRARY_PATH is not evaluated by arm-*-ld
set(LIB_DIRS
  "${SYSROOT_PATH}/usr/lib/arm-linux-gnueabihf"
	"${TOOLCHAIN_PATH}/arm-linux-gnueabihf/lib"
	"${TOOLCHAIN_PATH}/arm-linux-gnueabihf/libc/usr/lib"
	"${TOOLCHAIN_PATH}/arm-linux-gnueabihf/libc/lib"
	"${TOOLCHAIN_PATH}/arm-linux-gnueabihf/libc"
	"${TOOLCHAIN_PATH}/lib"
	"${SYSROOT_PATH}/lib"
	"${SYSROOT_PATH}/opt/vc/lib"
	"${SYSROOT_PATH}/lib/arm-linux-gnueabihf"
	"${SYSROOT_PATH}/usr/local/lib"
	"${SYSROOT_PATH}/usr/lib"
	"${SYSROOT_PATH}/usr/lib/arm-linux-gnueabihf/blas"
	"${SYSROOT_PATH}/usr/lib/arm-linux-gnueabihf/lapack"
)
# You can additionally check the linker paths if you add the flags ' -Xlinker --verbose'
set(COMMON_FLAGS "-I${SYSROOT_PATH}/usr/include -I${SYSROOT_PATH}/usr/include/arm-linux-gnueabihf -I${TOOLCHAIN_PATH}/arm-linux-gnueabihf/libc ")
FOREACH(LIB ${LIB_DIRS})
	set(COMMON_FLAGS "${COMMON_FLAGS} -L${LIB} -Wl,-rpath-link,${LIB} ")
ENDFOREACH()

set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${SYSROOT_PATH}/usr/lib/arm-linux-gnueabihf")

if(RASPBERRY_VERSION VERSION_GREATER 3)
	set(CMAKE_C_FLAGS "-mcpu=cortex-a72 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" CACHE STRING "Flags for Raspberry PI 4")
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "Flags for Raspberry PI 4")
elseif(RASPBERRY_VERSION VERSION_GREATER 2)
	set(CMAKE_C_FLAGS "-mcpu=cortex-a53 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" CACHE STRING "Flags for Raspberry PI 3")
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "Flags for Raspberry PI 3")
elseif(RASPBERRY_VERSION VERSION_GREATER 1)
	set(CMAKE_C_FLAGS "-mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" CACHE STRING "Flags for Raspberry PI 2")
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "Flags for Raspberry PI 2")
else()
	set(CMAKE_C_FLAGS "-mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard ${COMMON_FLAGS}" CACHE STRING "Flags for Raspberry PI 1 B+ Zero")
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "Flags for Raspberry PI 1 B+ Zero")
endif()

set(CMAKE_EXE_LINKER_FLAGS "-B${TOOLCHAIN_PATH}/arm-linux-gnueabihf/libc/usr/lib")

set(CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX};${CMAKE_PREFIX_PATH};${CMAKE_SYSROOT}")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# list(APPEND CMAKE_PREFIX_PATH "$ENV{HOME}/raspi/qt5pi")


# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

unset(CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES)
unset(CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES)
