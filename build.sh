#!/usr/bin/env bash
# =========================================
#         _____              _      
#        |  ___| __ ___  ___| |__   
#        | |_ | '__/ _ \/ __| '_ \  
#        |  _|| | |  __/\__ \ | | | 
#        |_|  |_|  \___||___/_| |_| 
#                              
# =========================================
#  
#  The Fresh Project
#  Copyright (C) 2019-2022 TenSeventy7
#                2024 PeterKnecht93
#  
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#  
#  =========================
#

set -e

# [
TOP="$PWD"
TOOLCHAIN="$HOME/Android/toolchains/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu"
TOOLCHAIN_EXT="$TOP/toolchain"

script_echo() { echo "  $1"; }
# ]

##
## Verify toolchain
##
if [ -d "$TOOLCHAIN" ]; then
	script_echo "I: Toolchain found at default location."

	export PATH="$TOOLCHAIN/bin:$PATH"
	export LD_LIBRARY_PATH="$TOOLCHAIN/lib:$LD_LIBRARY_PATH"
else
	if [ -d "$TOOLCHAIN_EXT" ]; then
		script_echo "I: Toolchain found at repository root."
	else
		script_echo "I: Toolchain not found at default location or repository root."
		script_echo "   Downloading recommended toolchain at $TOOLCHAIN_EXT..."

		mkdir -p "$TOOLCHAIN_EXT"
		wget -O "$TOOLCHAIN_EXT/toolchain.tar.xz" \
			https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/aarch64-linux-gnu/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu.tar.xz &>/dev/null

		unxz "$TOOLCHAIN_EXT/toolchain.tar.xz"
		tar --strip-components=1 -xf "$TOOLCHAIN_EXT/toolchain.tar" -C "$TOOLCHAIN_EXT"
		rm -f "$TOOLCHAIN_EXT/toolchain.tar"
	fi

	export PATH="$TOOLCHAIN_EXT/bin:$PATH"
	export LD_LIBRARY_PATH="$TOOLCHAIN_EXT/lib:$LD_LIBRARY_PATH"
fi
script_echo " "

##
## Compile FreshNxtInstaller
##
script_echo "I: Compiling FreshNxtInstaler..."
make clean
make --quiet --jobs "$(nproc)"

exit 0
