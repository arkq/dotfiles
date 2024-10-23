# Awesome WM Support - CMakeList.txt
# Copyright (c) 2024 Arkadiusz Bokowy
#
# Licensed under the terms of the MIT license.

cmake_minimum_required(VERSION 3.12)

project(
  alsamixer-glib
  VERSION 1.0.0
  LANGUAGES C)

include(GNUInstallDirs)

find_package(PkgConfig REQUIRED)
pkg_check_modules(ALSA REQUIRED IMPORTED_TARGET alsa)
pkg_check_modules(GOBJECT2 REQUIRED IMPORTED_TARGET gobject-2.0)
pkg_check_modules(GI REQUIRED gobject-introspection-1.0)
pkg_get_variable(GI_GIRDIR gobject-introspection-1.0 girdir)
pkg_get_variable(GI_TYPELIBDIR gobject-introspection-1.0 typelibdir)

set(SOURCES
  ${CMAKE_SOURCE_DIR}/alsamixer.c
  ${CMAKE_SOURCE_DIR}/alsamixer.h)

add_library(alsamixer-glib SHARED ${SOURCES})
target_link_libraries(alsamixer-glib PkgConfig::ALSA PkgConfig::GOBJECT2)

set(GIR_NAMESPACE AlsaMixer)
set(GIR_NS_VERSION 1.0)
set(GIR_FILENAME ${GIR_NAMESPACE}-${GIR_NS_VERSION}.gir)
set(GIR_TYPELIB ${GIR_NAMESPACE}-${GIR_NS_VERSION}.typelib)

add_custom_command(
  TARGET alsamixer-glib
  POST_BUILD
  COMMAND
    g-ir-scanner
    --warn-all
    --no-libtool
    --namespace=${GIR_NAMESPACE}
    --nsversion=${GIR_NS_VERSION}
    --identifier-prefix=AlsaMixer
    --symbol-prefix=alsa_mixer_
    --include=GObject-2.0
    --library=alsamixer-glib
    -L${CMAKE_BINARY_DIR}
    --output ${CMAKE_BINARY_DIR}/${GIR_FILENAME}
    ${SOURCES}
  COMMAND
    g-ir-compiler
    --output ${CMAKE_BINARY_DIR}/${GIR_TYPELIB}
    ${CMAKE_BINARY_DIR}/${GIR_FILENAME}
  BYPRODUCTS
  ${CMAKE_BINARY_DIR}/${GIR_FILENAME}
  ${CMAKE_BINARY_DIR}/${GIR_TYPELIB})

install(
  TARGETS alsamixer-glib
  DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(
  FILES ${CMAKE_BINARY_DIR}/${GIR_FILENAME}
  DESTINATION ${GI_GIRDIR})
install(
  FILES ${CMAKE_BINARY_DIR}/${GIR_TYPELIB}
  DESTINATION ${GI_TYPELIBDIR})
