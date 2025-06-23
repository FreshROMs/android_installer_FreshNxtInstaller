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

declare -A TARGET_DIRS=(
    [libpng]="$TOP/libs/png"
    [libfreetype]="$TOP/libs/freetype"
    [libziparchive]="$TOP/libs/ziparchive"
    [core]="$TOP/vendor/core"
    [logging]="$TOP/vendor/logging"
    [libbase]="$TOP/vendor/libbase"
    [googletest]="$TOP/vendor/googletest"
)

script_echo() { echo -e "  $1"; }
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
## Apply patches
##
script_echo "I: Applying patches..."
for target in "$TOP/patches/"*; do
    TARGET=$(basename "$target")
	TARGET_DIR="${TARGET_DIRS[$TARGET]}"

	# Check if target is valid
    if [ -z "$TARGET_DIR" ]; then
        script_echo "E: Invalid patch target: '$TARGET'!"
        script_echo "   Aborting... \n"
        exit 1
    fi

    cd "${TARGET_DIRS[$TARGET]}"
    for PATCH_FILE in "$target/"*.patch; do
		PATCH_SUBJECT=$(sed -n 's/^Subject: \[PATCH\] //p' "$PATCH_FILE" 2>/dev/null)
		[ ! -f "$PATCH_FILE" ] && continue

		# Check if patch is already applied
        if patch -p1 -R -N -t --dry-run < "$PATCH_FILE" >/dev/null; then
            script_echo "  - Already applied '$PATCH_SUBJECT'."
            continue
        fi

        # Check if patch can be applied
        if ! patch -p1 -N -t --dry-run < "$PATCH_FILE" >/dev/null; then
			script_echo " "
            script_echo "E: Failed to apply '$PATCH_SUBJECT'! \n"
            exit 1
        fi

        # Apply the patch
        script_echo "  - Applying '$PATCH_SUBJECT'."
        patch -p1 -N -t --no-backup-if-mismatch < "$PATCH_FILE" >/dev/null
	done
done
script_echo " "

##
## Compile FreshNxtInstaller
##
script_echo "I: Compiling FreshNxtInstaler..."
cd "$TOP"
make clean
make --quiet --jobs "$(nproc)"

exit 0
