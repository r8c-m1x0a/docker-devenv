FROM ubuntu:22.04

ENV PATH=/usr/local/m32c-elf/bin:$PATH
ARG BIN_UTIL_VER=2.40
ARG GCC_VER=12.2.0
ARG NEW_LIB_VER=4.1.0

RUN \
  apt-get -y update && \
  apt-get -y install texinfo libgmp-dev libmpfr-dev libmpc-dev diffutils automake zlib1g-dev \
    clang wget build-essential git libboost-dev scons cmake gdb doxygen lcov locales-all

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
  cd libgcc && \
  rm fp-bit.c; touch fp-bit.c && \
  for i in unwind-*.c; do rm $i; touch $i; done && \
  cd ~/r8c/gcc-${GCC_VER}/gcc/config/m32c && \
  {  \
     echo '--- old/m32c.cc 2022-08-19 08:09:52.648663341 +0000'; \
     echo '+++ new/m32c.cc 2023-03-25 01:46:20.722151623 +0000'; \
     echo '@@ -4013,9 +4013,13 @@'; \
     echo ' m32c_leaf_function_p (void)'; \
     echo ' {'; \
     echo '   int rv;'; \
     echo '+  struct sequence_stack *tem;'; \
     echo ' '; \
     echo '   push_topmost_sequence ();'; \
     echo '+  tem = get_current_sequence ()->next;'; \
     echo '+  get_current_sequence ()->next = nullptr;'; \
     echo '   rv = leaf_function_p ();'; \
     echo '+  get_current_sequence ()->next = tem;'; \
     echo '   pop_topmost_sequence ();'; \
     echo '   return rv;'; \
     echo ' }'; \
  } > patch.gcc && \
  patch m32c.cc < patch.gcc && \
  cd ~/r8c/gcc-${GCC_VER}/gcc && \
  { \
    echo '--- old/reload1.cc	2023-04-15 09:24:49.590915878 +0900'; \
    echo '+++ new/reload1.cc	2023-04-15 09:25:45.154340175 +0900'; \
    echo '@@ -2062,15 +2062,11 @@'; \
    echo ' 		   reg_class_names[rclass]);'; \
    echo '   else'; \
    echo '     {'; \
    echo '-      error ("unable to find a register to spill in class %qs",'; \
    echo '-	     reg_class_names[rclass]);'; \
    echo '-'; \
    echo '       if (dump_file)'; \
    echo ' 	{'; \
    echo ' 	  fprintf (dump_file, "\\nReloads for insn # %d\\n", INSN_UID (insn));'; \
    echo ' 	  debug_reload_to_stream (dump_file);'; \
    echo ' 	}'; \
    echo '-      fatal_insn ("this is the insn:", insn);'; \
    echo '     }'; \
    echo ' }'; \
  } > patch.gcc && \
  cat patch.gcc && \
  patch reload1.cc < patch.gcc && \
  mkdir ~/r8c/gcc-${GCC_VER}/m32c_build && \
  cd ~/r8c/gcc-${GCC_VER}/m32c_build && \
  ../configure --prefix=/usr/local/m32c-elf --target=m32c-elf --enable-languages=c --disable-libssp --with-newlib \
    --disable-nls --disable-threads --disable-libgomp --disable-libmudflap --disable-libstdcxx-pch --disable-multilib \
    --enable-lto --with-system-zlib --disable-float --disable-atomic && \
  make && \
  make install && \
  ln -s /usr/local/m32c-elf/bin/m32c-elf-gcc /usr/local/m32c-elf/bin/m32c-elf-cc
  
RUN \
  cd ~/r8c && \
  wget ftp://sourceware.org/pub/newlib/newlib-${NEW_LIB_VER}.tar.gz && \
  tar xf newlib-${NEW_LIB_VER}.tar.gz
RUN \
  cd ~/r8c/newlib-${NEW_LIB_VER} && \
  rm newlib/libc/stdlib/ldtoa.c; touch newlib/libc/stdlib/ldtoa.c && \
  rm newlib/libc/stdio/vfwprintf.c; touch newlib/libc/stdio/vfwprintf.c && \
  rm newlib/libc/stdio/vfscanf.c; touch newlib/libc/stdio/vfscanf.c && \
  rm newlib/libc/stdio/vfwscanf.c; touch newlib/libc/stdio/vfwscanf.c && \
  rm newlib/libm/math/k_rem_pio2.c; touch newlib/libm/math/k_rem_pio2.c && \
  rm newlib/libm/math/kf_rem_pio2.c; touch newlib/libm/math/kf_rem_pio2.c && \
  rm newlib/libc/stdlib/arc4random.c; touch newlib/libc/stdlib/arc4random.c && \
  rm newlib/libc/time/wcsftime.c; touch newlib/libc/time/wcsftime.c && \
  mkdir m32c_build && \
  cd m32c_build && \
  ../configure --target=m32c-elf --prefix=/usr/local/m32c-elf --disable-newlib-io-float --disable-newlib-supplied-syscalls --enable-newlib-reent-small --enable-newlib-nano-malloc --enable-lite-exit --enable-newlib-global-atexit --enable-newlib-nano-formatted-io && \
  make && \
  make install && \
  cd ~/r8c && \
  rm -rf newlib-${NEW_LIB_VER}.tar.gz newlib-${NEW_LIB_VER}

RUN \
  cd ~/r8c/gcc-${GCC_VER} && \
  rm libstdc++-v3/src/c++17/fs_ops.cc; touch libstdc++-v3/src/c++17/fs_ops.cc && \
  rm libstdc++-v3/src/c++17/fs_path.cc; touch libstdc++-v3/src/c++17/fs_path.cc && \
  rm libstdc++-v3/src/c++17/fs_dir.cc; touch libstdc++-v3/src/c++17/fs_dir.cc && \
  sed -i 's/_Error_formatter::_M_error() const/__attribute__((optimize("O0"))) _Error_formatter::_M_error() const/'  libstdc++-v3/src/c++11/debug.cc && \
  { \
    echo '--- old/memory_resource.cc	2023-04-15 11:02:21.594066313 +0900'; \
    echo '+++ new/memory_resource.cc	2023-04-15 11:03:12.389340622 +0900'; \
    echo '@@ -290,9 +290,9 @@'; \
    echo '   {'; \
    echo '     const size_t n = std::max(bytes, _M_next_bufsiz);'; \
    echo '     const size_t m = aligned_ceil(alignment, alignof(std::max_align_t));'; \
    echo '-    auto [p, size] = _Chunk::allocate(_M_upstream, n, m, _M_head);'; \
    echo '-    _M_current_buf = p;'; \
    echo '-    _M_avail = size;'; \
    echo '+    auto a = _Chunk::allocate(_M_upstream, n, m, _M_head);'; \
    echo '+    _M_current_buf = a.first;'; \
    echo '+    _M_avail = a.second;'; \
    echo '     _M_next_bufsiz *= _S_growth_factor;'; \
    echo '   }'; \
  } > patch.gcc && \
  patch libstdc++-v3/src/c++17/memory_resource.cc < patch.gcc && \
  { \
    echo '--- /old/stl_algobase.h	2023-03-25 05:59:50.791128044 +0000'; \
    echo '+++ libstdc++-v3/include/bits/stl_algobase.h	2023-03-25 06:01:01.758521702 +0000'; \
    echo '@@ -1835,16 +1835,26 @@'; \
    echo ' 	  if constexpr (__is_byte_iter<_InputIter1>)'; \
    echo ' 	    if constexpr (__is_byte_iter<_InputIter2>)'; \
    echo ' 	      {'; \
    echo '-		const auto [__len, __lencmp] = _GLIBCXX_STD_A::'; \
    echo '+//		const auto [__len, __lencmp] = _GLIBCXX_STD_A::'; \
    echo '+//		  __min_cmp(__last1 - __first1, __last2 - __first2);'; \
    echo '+//		if (__len)'; \
    echo '+//		  {'; \
    echo '+//		    const auto __c'; \
    echo '+//		      = __builtin_memcmp(&*__first1, &*__first2, __len) <=> 0;'; \
    echo '+//		    if (__c != 0)'; \
    echo '+//		      return __c;'; \
    echo '+//		  }'; \
    echo '+//		return __lencmp;'; \
    echo '+		const auto a = _GLIBCXX_STD_A::'; \
    echo ' 		  __min_cmp(__last1 - __first1, __last2 - __first2);'; \
    echo '-		if (__len)'; \
    echo '+		if (a.first)'; \
    echo ' 		  {'; \
    echo ' 		    const auto __c'; \
    echo '-		      = __builtin_memcmp(&*__first1, &*__first2, __len) <=> 0;'; \
    echo '+		      = __builtin_memcmp(&*__first1, &*__first2, a.first) <=> 0;'; \
    echo ' 		    if (__c != 0)'; \
    echo ' 		      return __c;'; \
    echo ' 		  }'; \
    echo '-		return __lencmp;'; \
    echo '+		return a.second;'; \
    echo ' 	      }'; \
    echo ' '; \
    echo '       while (__first1 != __last1)'; \
  } > patch.gcc && \
  patch libstdc++-v3/include/bits/stl_algobase.h < patch.gcc && \
  cd m32c_build && \
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
