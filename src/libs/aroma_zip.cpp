/*
 * Copyright (C) 2011 Ahmad Amarullah ( http://amarullz.com/ )
 *               2025 The Fresh Project ( https://github.com/FreshROMs )
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Descriptions:
 * -------------
 * libziparchive wrapper for AROMA Installer
 *
 */

#include <fcntl.h>
#include <sys/stat.h>
#include <ziparchive/zip_archive.h>

#include <installer/aroma.h>

extern "C" {

/*****************************[ GLOBAL VARIABLES ]*****************************/
static ZipArchiveHandle zip = nullptr;

/*********************************[ FUNCTIONS ]********************************/

//-- AROMA ZIP Init
byte az_init(const char *filename) {
  if (OpenArchive(filename, &zip) != 0) {
    return 0;
  }
  mkdir(AROMA_TMP, 0755);
  return 1;
}

//-- AROMA ZIP Close
void az_close() {
  if (zip != nullptr) {
    CloseArchive(zip);
    zip = nullptr;
  }
}

//-- Extract To Memory
byte az_readmem(AZMEM *out, const char *zpath, byte bytesafe) {
  ZipEntry64 entry;
  if (FindEntry(zip, std::string_view(zpath), &entry) != 0) {
    return 0;
  }

  out->sz = entry.uncompressed_length + (bytesafe ? 0 : 1);
  out->data = (byte*)malloc(out->sz);
  if (!out->data) {
    return 0;
  }

  int result = ExtractToMemory(zip, &entry, out->data, entry.uncompressed_length);
  if (result != 0) {
    free(out->data);
    return 0;
  }

  if (!bytesafe) {
    ((char *)out->data)[entry.uncompressed_length] = '\0';
  }

  return 1;
}

//-- Extract To File
byte az_extract(const char *zpath, const char *dest) {
  ZipEntry64 entry;
  if (FindEntry(zip, std::string_view(zpath), &entry) != 0) {
    return 0;
  }

  unlink(dest);
  int fd = creat(dest, 0755);
  if (fd < 0) {
    return 0;
  }

  int result = ExtractEntryToFile(zip, &entry, fd);
  close(fd);
  return (result == 0) ? 1 : 0;
}

}
