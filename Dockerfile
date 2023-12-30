# Use this Dockerfile to build u-boot for Rockchip boards.
# It was written to run on an ARM MacBook.
#
# Run the following commands from a local u-boot clone, to build it for the evb-rk3128 board:
#
# docker build -t u-boot-build .
# docker run -it --rm -v "$(pwd):/sources/u-boot" u-boot-dev ./make.sh evb-rk3128

# This needs to be run on a x86_64 machine, as the Linaro toolchain is not multiarch.
FROM --platform=linux/amd64 debian

# Install dependencies
RUN apt-get update && apt-get install -y \
    # gcc for cross-compiling
    gcc-arm-linux-gnueabi \
    # tools for building, such as make
    build-essential \
    # curses support, for menuconfig
    libncurses-dev  \
    # git for cloning
    git \
    # wget for downloading Linaro toolchain
    wget \
    # an improved version of awk, needed for build scripts
    gawk \
    # bc needed for build scripts
    bc \
    # cleanup
    && rm -rf /var/lib/apt/lists/*

WORKDIR /sources/u-boot

# Linaro toolchain
# This version is recommended by Rockchip
ARG LINARO_URL=https://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/arm-linux-gnueabihf/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz
ARG LINARO_DIR=/sources/prebuilts/gcc/linux-x86/arm/
# Download and extract the toolchain
RUN mkdir -p $LINARO_DIR && wget -qc $LINARO_URL -O - | tar -xJ -C $LINARO_DIR

# Clone the rkbin and u-boot repositories
# Their paths need to be siblings of the toolchain, as they are hardcoded relative to each other in the build scripts
RUN git clone https://github.com/rockchip-linux/rkbin.git /sources/rkbin
RUN git clone https://github.com/rockchip-linux/u-boot.git /sources/u-boot
