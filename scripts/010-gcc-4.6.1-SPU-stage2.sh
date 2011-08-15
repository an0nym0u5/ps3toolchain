#!/bin/sh -e
# gcc-4.6.1-SPU-stage2.sh by Dan Peori (dan.peori@oopo.net)

if [ ! -d gcc-4.6.1 ]; then

  ## Download the source code.
  wget --continue ftp://ftp.gnu.org/gnu/gcc/gcc-4.6.1/gcc-4.6.1.tar.bz2

  ## Download the library source code.
  wget --continue ftp://ftp.gmplib.org/pub/gmp-5.0.2/gmp-5.0.2.tar.bz2
  wget --continue http://www.multiprecision.org/mpc/download/mpc-0.9.tar.gz
  wget --continue http://www.mpfr.org/mpfr-current/mpfr-3.0.1.tar.bz2
  wget --continue http://www.mpfr.org/mpfr-current/allpatches -O mpfr-allpatches

  ## Unpack the source code.
  rm -Rf gcc-4.6.1 && tar xfvj gcc-4.6.1.tar.bz2

  ## Patch the source code.
  cat ../patches/gcc-4.6.1-PS3.patch | patch -p1 -d gcc-4.6.1

  ## Enter the source code directory.
  cd gcc-4.6.1

  ## Unpack the library source code.
  tar xfvj ../gmp-5.0.2.tar.bz2 && ln -s gmp-5.0.2 gmp
  tar xfvz ../mpc-0.9.tar.gz && ln -s mpc-0.9 mpc
  tar xfvj ../mpfr-3.0.1.tar.bz2 && ln -s mpfr-3.0.1 mpfr

  ## Patch the latest bug fixes
  cat ../mpfr-allpatches | patch -p1 -d mpfr-3.0.1

  ## Leave the source code directory.
  cd ..

fi

if [ ! -d gcc-4.6.1/build-spu ]; then

  ## Create the build directory.
  mkdir gcc-4.6.1/build-spu

fi

## Enter the build directory.
cd gcc-4.6.1/build-spu

## Configure the build.
../configure --prefix="$PS3DEV/spu" --target="spu" \
    --disable-dependency-tracking \
    --disable-libssp \
    --disable-multilib \
    --disable-nls \
    --disable-shared \
    --disable-win32-registry \
    --enable-languages="c,c++" \
    --enable-lto \
    --enable-threads \
    --with-newlib \
   

## Compile and install.
${MAKE:-make} -j 4 all && ${MAKE:-make} install
