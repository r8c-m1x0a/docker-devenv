FROM ubuntu:22.04

ENV PATH=/usr/local/m32c-elf/bin:$PATH
ARG BIN_UTIL_VER=2.40
ARG GCC_VER=6.5.0
ARG NEW_LIB_VER=2.5.0

RUN \
  apt-get -y update && \
  apt-get -y install texinfo libgmp-dev libmpfr-dev libmpc-dev diffutils automake zlib1g-dev \
    clang wget build-essential git libboost-dev scons cmake gdb lcov doxygen

RUN \
  mkdir ~/r8c && \
  cd ~/r8c && \
  wget https://ftp.gnu.org/gnu/binutils/binutils-${BIN_UTIL_VER}.tar.gz && \
  tar xf binutils-${BIN_UTIL_VER}.tar.gz && \
  cd binutils-${BIN_UTIL_VER} && \
  mkdir m32c_build && \
  cd m32c_build && \
  ../configure --target=m32c-elf --prefix=/usr/local/m32c-elf --disable-nls --with-system-zlib && \
  make && \
  make install && \
  cd ~/r8c && \
  rm -rf binutils-${BIN_UTIL_VER}.tar.gz binutils-${BIN_UTIL_VER}

RUN \
  cd ~/r8c && \
  wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz && \
  tar xf gcc-${GCC_VER}.tar.gz && \
  cd gcc-${GCC_VER} && \
  mkdir m32c_build && \
  cd m32c_build && \
  ../configure --prefix=/usr/local/m32c-elf --target=m32c-elf --enable-languages=c --disable-libssp --with-newlib \
    --disable-nls --disable-threads --disable-libgomp --disable-libmudflap --disable-libstdcxx-pch --disable-multilib \
    --enable-lto --with-system-zlib --disable-float --disable-atomic && \
  make && \
  make install
  
RUN \
  cd ~/r8c && \
  wget ftp://sourceware.org/pub/newlib/newlib-${NEW_LIB_VER}.tar.gz && \
  tar xf newlib-${NEW_LIB_VER}.tar.gz && \
  cd newlib-${NEW_LIB_VER} && \
  mkdir m32c_build && \
  cd m32c_build && \
  ../configure --target=m32c-elf --prefix=/usr/local/m32c-elf && \
  make && \
  make install && \
  cd ~/r8c && \
  rm -rf newlib-${NEW_LIB_VER}.tar.gz newlib-${NEW_LIB_VER}

RUN \
  cd ~/r8c/gcc-${GCC_VER}/m32c_build && \
  ../configure --prefix=/usr/local/m32c-elf --target=m32c-elf --enable-languages=c,c++ --disable-libssp \
    --with-newlib --disable-nls --disable-threads --disable-libgomp --disable-libmudflap --disable-libstdcxx-pch \
    --disable-multilib --enable-lto --with-system-zlib --disable-float --disable-atomic && \
  make && \
  make install && \
  cd ~/r8c && \
  rm -rf gcc-${GCC_VER}.tar.gz gcc-${GCC_VER}  

RUN \
  cd ~/r8c && \
  git clone https://github.com/google/googletest.git -b v1.13.0 && \
  cd googletest && \
  mkdir build && \
  cd build && \
  cmake .. && \
  make && \
  make install && \
  cd ../.. && \
  rm -rf googletest

RUN \
  cd ~/r8c && \
  mkdir src && \
  cd src && \
  wget https://github.com/r8c-m1x0a/io/raw/main/src/r8c-m1xa-io.cpp && \
  wget https://github.com/r8c-m1x0a/io/raw/main/src/r8c-m1xa-io.h
