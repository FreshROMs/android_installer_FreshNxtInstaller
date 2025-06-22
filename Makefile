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
ARCH := aarch64
CROSS_COMPILE := aarch64-linux-gnu-

CC := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++
AS := $(CROSS_COMPILE)as
AR := $(CROSS_COMPILE)ar

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
	libs/zlib/adler32.c \
	libs/zlib/crc32.c \
	libs/zlib/infback.c \
	libs/zlib/inffast.c \
	libs/zlib/inflate.c \
	libs/zlib/inftrees.c \
	libs/zlib/zutil.c \
\
	libs/png/png.c \
	libs/png/pngerror.c \
	libs/png/pnggccrd.c \
	libs/png/pngget.c \
	libs/png/pngmem.c \
	libs/png/pngpread.c \
	libs/png/pngread.c \
	libs/png/pngrio.c \
	libs/png/pngrtran.c \
	libs/png/pngrutil.c \
	libs/png/pngset.c \
	libs/png/pngtrans.c \
	libs/png/pngvcrd.c \
\
	libs/minutf8/minutf8.c \
\
	libs/minzip/DirUtil.c \
	libs/minzip/Hash.c \
	libs/minzip/Inlines.c \
	libs/minzip/SysUtil.c \
	libs/minzip/Zip.c \
\
	libs/freetype/autofit/autofit.c \
	libs/freetype/base/basepic.c \
	libs/freetype/base/ftapi.c \
	libs/freetype/base/ftbase.c \
	libs/freetype/base/ftbbox.c \
	libs/freetype/base/ftbitmap.c \
	libs/freetype/base/ftglyph.c \
	libs/freetype/base/ftinit.c \
	libs/freetype/base/ftpic.c \
	libs/freetype/base/ftstroke.c \
	libs/freetype/base/ftsynth.c \
	libs/freetype/base/ftsystem.c \
	libs/freetype/cff/cff.c \
	libs/freetype/pshinter/pshinter.c \
	libs/freetype/psnames/psnames.c \
	libs/freetype/raster/raster.c \
	libs/freetype/sfnt/sfnt.c \
	libs/freetype/smooth/smooth.c \
	libs/freetype/truetype/truetype.c \
	libs/freetype/base/ftlcdfil.c \
\
	$(wildcard src/edify/*.c) \
	$(wildcard src/libs/*.c) \
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
	-Ilibs/minutf8/include \
	-Iinclude/aroma \
	-Iinclude \
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
	-fPIC -DPIC \
	-D_FILE_OFFSET_BITS=64 \
	-DFT2_BUILD_LIBRARY=1 \
	-D_AROMA_NODEBUG \
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
	-fPIC -DPIC \
	-D_FILE_OFFSET_BITS=64 \
	$(INCLUDES)

ASFLAGS :=

##
## Linker flags
##
LDLIBS := \
	-lm \
	-lpthread

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
