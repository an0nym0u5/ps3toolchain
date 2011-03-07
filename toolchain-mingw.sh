#!/bin/bash
# toolchain-mingw.sh by Miigotu (miigotu@hotmail.com)

MINGW32EXPORTS=\
('export GITINSTALLDIR=/c/msysgit' \
'export PATH="$PATH:$GITINSTALLDIR/bin"' \
'export PATH="$PATH:$GITINSTALLDIR/mingw/bin"' \
'export PYINSTALLDIR=/c/python27' \
'export PATH="$PATH:$PYINSTALLDIR"' \
'export PS3DEV=/usr/local/ps3dev' \
'export PATH="$PATH:$PS3DEV/bin"' \
'export PATH="$PATH:$PS3DEV/host/ppu/bin"' \
'export PATH="$PATH:$PS3DEV/host/spu/bin"' \
'export PSL1GHT=$PS3DEV/psl1ght' \
'export PATH="$PATH:$PSL1GHT/host/bin"')

if [ $MSYSTEM == MINGW32 ]; then
	NEWLINE=0
	RESTART=0
	for((i = 0; i < 11; i++)); do
		if ! grep -q "${MINGW32EXPORTS[${i}]}" /etc/profile; then
			if [ $NEWLINE -ne 1 ]; then
				echo >> /etc/profile ##In cases where no new line is at EOF.
				NEWLINE=1
			fi
			echo ${MINGW32EXPORTS[${i}]} >> /etc/profile
			RESTART=1
		fi
	done
	if [ $RESTART -eq 1 ]; then
		echo "Please restart mingw, or type '. /etc/profile' (without quotes)"
		echo "and then run this script again."
		exit 1
	fi

	## Install Dependancy packages
	mingw-get install msys-wget libz libpdcurses gmp pexports msys-patch

	## Create the build directory.
	mkdir -p build && cd build || { echo "ERROR: Could not create the build directory."; exit 1; }

	## Install libelf
	wget http://www.mr511.de/software/libelf-0.8.13.tar.gz
	tar -zxvf libelf-0.8.13.tar.gz
	cd libelf-0.8.13
	./configure --prefix="/mingw"
	make
	make install
	
	## Install pkg-config
	wget ftp://mirrors.kernel.org/sourceware/cygwin/release/pkg-config/pkg-config-0.23b-10.tar.bz2
	wget ftp://mirrors.kernel.org/sourceware/cygwin/release/cygwin/cygwin-1.7.8-1.tar.bz2
	tar xjOf pkg-config-0.23b-10.tar.bz2 usr/bin/pkg-config.exe > /mingw/bin/pkg-config.exe
	tar xjOf cygwin-1.7.8-1.tar.bz2 usr/bin/cygwin1.dll > /mingw/bin/cygwin1.dll

	## Convert python.dll to a shared library
	PYDLL="$WINDIR\SysWOW64\python27.dll"
	pexports "$PYDLL" > python27.def
	if [ $? != 0 ]; then
		PYDLL="$WINDIR\System32\python27.dll"
		pexports "$PYDLL" > python27.def
	fi
	dlltool --dllname "$PYDLL" --def python27.def --output-lib libpython27.a 
	mv libpython27.a $PYINSTALLDIR/libs

	## Enter the ps3toolchain directory.
	cd ..

	## Run the toolchain script.
	./toolchain.sh $@ || { echo "ERROR: Could not run the toolchain script."; exit 1; }
else
	echo "MinGW was not detected as your kernel, exitting."
fi