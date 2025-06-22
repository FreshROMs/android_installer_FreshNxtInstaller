##
## Version info
##
AROMA_NAME    := Fresh Install Wizard
AROMA_VERSION := 13.2.1.1
AROMA_BUILD   := $(shell date +%s)
AROMA_CN      := Red-Eyes Black Dragon

##
## Compiler options
##
API := 34
ARCH := aarch64
TARGET := $(ARCH)-linux-android$(API)

CC := $(TARGET)-clang
CXX := $(TARGET)-clang++
AS := $(TARGET)-clang
AR := $(TARGET)ar

##
## Directories
##
TOP := $(PWD)
OUT_DIR := $(TOP)/out
BUILD_DIR := $(OUT_DIR)/build
TMP_DIR := $(OUT_DIR)/tmp

##
## Input
##
SOURCES := \
	libs/png/png.c \
	libs/png/pngerror.c \
	libs/png/pngget.c \
	libs/png/pngmem.c \
	libs/png/pngpread.c \
	libs/png/pngread.c \
	libs/png/pngrio.c \
	libs/png/pngrtran.c \
	libs/png/pngrutil.c \
	libs/png/pngset.c \
	libs/png/pngtrans.c \
	libs/png/pngwio.c \
	libs/png/pngwrite.c \
	libs/png/pngwtran.c \
	libs/png/pngwutil.c \
	libs/png/arm/arm_init.c \
	libs/png/arm/filter_neon_intrinsics.c \
	libs/png/arm/palette_neon_intrinsics.c \
\
	libs/minutf8/minutf8.c \
\
	libs/freetype/src/autofit/autofit.c \
	libs/freetype/src/base/ftinit.c \
	libs/freetype/src/base/ftbase.c \
	libs/freetype/src/base/ftbitmap.c \
	libs/freetype/src/base/ftdebug.c \
	libs/freetype/src/base/ftglyph.c \
	libs/freetype/src/base/ftmm.c \
	libs/freetype/src/base/ftsynth.c \
	libs/freetype/src/base/ftsystem.c \
	libs/freetype/src/cff/cff.c \
	libs/freetype/src/gzip/ftgzip.c \
	libs/freetype/src/lzw/ftlzw.c \
	libs/freetype/src/psaux/psaux.c \
	libs/freetype/src/pshinter/pshinter.c \
	libs/freetype/src/psnames/psnames.c \
	libs/freetype/src/raster/raster.c \
	libs/freetype/src/sfnt/sfnt.c \
	libs/freetype/src/smooth/ftgrays.c \
	libs/freetype/src/smooth/ftsmooth.c \
	libs/freetype/src/truetype/truetype.c \
\
	vendor/logging/liblog/log_event_list.cpp \
	vendor/logging/liblog/log_event_write.cpp \
	vendor/logging/liblog/logd_writer.cpp \
	vendor/logging/liblog/logger_name.cpp \
	vendor/logging/liblog/logger_read.cpp \
	vendor/logging/liblog/logger_write.cpp \
	vendor/logging/liblog/logprint.cpp \
	vendor/logging/liblog/pmsg_writer.cpp \
	vendor/logging/liblog/properties.cpp \
\
	vendor/libbase/abi_compatibility.cpp \
	vendor/libbase/chrono_utils.cpp \
	vendor/libbase/file.cpp \
	vendor/libbase/hex.cpp \
	vendor/libbase/logging.cpp \
	vendor/libbase/mapped_file.cpp \
	vendor/libbase/parsebool.cpp \
	vendor/libbase/parsenetaddress.cpp \
	vendor/libbase/posix_strerror_r.cpp \
	vendor/libbase/process.cpp \
	vendor/libbase/properties.cpp \
	vendor/libbase/stringprintf.cpp \
	vendor/libbase/strings.cpp \
	vendor/libbase/threads.cpp \
	vendor/libbase/test_utils.cpp \
\
	vendor/googletest/googletest/src/gtest-all.cc \
\
	libs/ziparchive/zip_archive.cc \
	libs/ziparchive/zip_archive_stream_entry.cc \
	libs/ziparchive/zip_cd_entry_map.cc \
	libs/ziparchive/zip_error.cpp \
	libs/ziparchive/zip_writer.cc \
	libs/ziparchive/incfs_support/signal_handling.cpp \
\
	$(wildcard src/edify/*.c) \
	$(wildcard src/libs/*.c) \
	$(wildcard src/libs/*.cpp) \
	$(wildcard src/controls/*.c) \
	$(wildcard src/main/*.c)

OBJS := \
	$(patsubst %.s,$(BUILD_DIR)/%.o,$(filter %.s,$(SOURCES))) \
	$(patsubst %.c,$(BUILD_DIR)/%.o,$(filter %.c,$(SOURCES))) \
	$(patsubst %.cc,$(BUILD_DIR)/%.o,$(filter %.cc,$(SOURCES))) \
	$(patsubst %.cpp,$(BUILD_DIR)/%.o,$(filter %.cpp,$(SOURCES)))

##
## Compiler flags
##
INCLUDES := \
	-Ilibs/png \
	-Iinclude/png \
	-Ilibs/minutf8/include \
	-Ilibs/freetype/include \
	-Iinclude/freetype \
	-Ivendor/core/libcutils/include \
	-Ivendor/logging/liblog/include \
	-Ivendor/libbase/include \
	-Ivendor/logging/liblog/include \
	-Ivendor/googletest/googletest \
	-Ivendor/googletest/googletest/include \
	-Ilibs/ziparchive/incfs_support/include \
	-Ilibs/ziparchive/include \
	-Iinclude/aroma \
	-Isrc/edify

AROMA_VERSION_FLAGS := \
	-DAROMA_NAME="\"$(AROMA_NAME)\"" \
	-DAROMA_VERSION="\"$(AROMA_VERSION)\"" \
	-DAROMA_BUILD="\"$(AROMA_BUILD)\"" \
	-DAROMA_BUILD_CN="\"$(AROMA_CN)\""

CFLAGS := \
	-O2 \
	-save-temps=obj \
	-fdata-sections \
	-ffunction-sections \
	-ftree-vectorize \
	-funsafe-math-optimizations \
	-fomit-frame-pointer \
	-flto \
	-fPIC -DPIC \
	-D_FILE_OFFSET_BITS=64 \
	-DFT_CONFIG_MODULES_H=\"ftmodule.h\" \
	-DFT2_BUILD_LIBRARY=1 \
	-D_AROMA_NODEBUG \
	-Wno-parentheses-equality \
	$(INCLUDES) \
	$(AROMA_VERSION_FLAGS)

CXXFLAGS := \
	-O2 \
	-save-temps=obj \
	-fdata-sections \
	-ffunction-sections \
	-ftree-vectorize \
	-funsafe-math-optimizations \
	-fomit-frame-pointer \
	-flto \
	-fPIC -DPIC \
	-D_FILE_OFFSET_BITS=64 \
	-DANDROID_DEBUGGABLE=0 \
	-DSNET_EVENT_LOG_TAG=1397638484 \
	-DLIBLOG_LOG_TAG=1006 \
	-Wno-c99-designator \
	-Wno-unused-value \
	-Wno-c++11-narrowing \
	-Wno-reorder-init-list \
	-Wno-vla-cxx-extension \
	-std=c++20 \
	$(INCLUDES)

ASFLAGS := $(CFLAGS)

##
## Linker flags
##
LDLIBS := \
	-lm \
	-lz

LDFLAGS := \
	-Wl,--gc-sections \
	-Wl,--strip-all \
	-static

##
## Targets
##
$(BUILD_DIR)/%.o: %.s   #-- Build rule for Assembly '.s' files
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.c   #-- Build rule for C '.c' files
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cc  #-- Build rule for C++ '.cc' files
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cpp #-- Build rule for C++ '.cpp' files
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

all: zip
	@echo "  I: Build complete."
	@echo "     Output files have been written to: $(OUT_DIR)"
	@echo " "

zip: bin
	@echo "  I: Building zip file..."
	@mkdir -p "$(TMP_DIR)"
	@cp -a "$(TOP)/assets/META-INF" "$(TMP_DIR)"
	@cp -a "$(OUT_DIR)/install_wizard-$(ARCH)"  "$(TMP_DIR)/META-INF/com/google/android/update-binary"

	@7z a "$(OUT_DIR)/install_wizard-$(ARCH).zip" "$(TMP_DIR)/"* 2>&1 | sed 's/^/    /'
	@echo " "

bin: $(OBJS)
	@mkdir -p "$(OUT_DIR)"
	@$(CXX) $(LDFLAGS) $(OBJS) $(LDLIBS) -o "$(OUT_DIR)/install_wizard-$(ARCH)"
	@echo " "

clean:
	@rm -rf "$(OUT_DIR)"

.PHONY: clean
