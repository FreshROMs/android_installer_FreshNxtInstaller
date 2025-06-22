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
NDK="$HOME/Android/Sdk/ndk/27.2.12479018"
NDK_EXT="$TOP/ndk"

script_echo() { echo "  $1"; }
# ]

##
## Verify NDK
##
if [ -d "$NDK" ]; then
	script_echo "I: NDK found at default location."

	export TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/linux-x86_64"
else
	if [ -d "$NDK_EXT" ]; then
		script_echo "I: NDK found at repository root."
	else
		script_echo "I: NDK not found at default location or repository root."
		script_echo "   Downloading NDK at $NDK_EXT..."

		wget -O "$TOP/ndk.zip" \
			https://dl.google.com/android/repository/android-ndk-r27c-linux.zip &>/dev/null

		unzip -q "$TOP/ndk.zip"
		mv 'android-ndk-r27c' "$NDK_EXT"
		rm -f "$TOP/ndk.zip"
	fi

	export TOOLCHAIN="$NDK_EXT/toolchains/llvm/prebuilt/linux-x86_64"
fi

export PATH="$TOOLCHAIN/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLCHAIN/lib:$LD_LIBRARY_PATH"
script_echo " "

##
## Compile FreshNxtInstaller
##
script_echo "I: Compiling FreshNxtInstaler..."
make clean
make --quiet --jobs "$(nproc)"

exit 0
