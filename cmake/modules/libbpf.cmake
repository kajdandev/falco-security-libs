#
# libbpf
#
option(USE_BUNDLED_LIBBPF "Enable building of the bundled libbpf" ${USE_BUNDLED_DEPS})

if(LIBBPF_INCLUDE)
    # we already have libbpf
elseif(NOT USE_BUNDLED_LIBBPF)
    find_path(LIBBPF_INCLUDE bpf/libbpf.h)
    find_library(LIBBPF_LIB NAMES bpf)
    if(LIBBPF_INCLUDE AND LIBBPF_LIB)
        message(STATUS "Found libbpf: include: ${LIBBPF_INCLUDE}, lib: ${LIBBPF_LIB}")
    else()
        message(FATAL_ERROR "Couldn't find system libbpf")
    endif()
else()
    set(LIBBPF_SRC "${PROJECT_BINARY_DIR}/libbpf-prefix/src")
    set(LIBBPF_BUILD_DIR "${LIBBPF_SRC}/libbpf-build")
    set(LIBBPF_INCLUDE "${LIBBPF_BUILD_DIR}/root/usr/include")
    set(LIBBPF_LIB "${LIBBPF_BUILD_DIR}/root/usr/lib64/libbpf.a")
    ExternalProject_Add(
        libbpf
        PREFIX "${PROJECT_BINARY_DIR}/libbpf-prefix"
        DEPENDS zlib
        URL "https://github.com/libbpf/libbpf/archive/refs/tags/v1.0.1.tar.gz"
        URL_HASH
        "SHA256=3d6afde67682c909e341bf194678a8969f17628705af25f900d5f68bd299cb03"
        CONFIGURE_COMMAND mkdir -p build root
        BUILD_COMMAND BUILD_STATIC_ONLY=y OBJDIR=${LIBBPF_BUILD_DIR}/build DESTDIR=${LIBBPF_BUILD_DIR}/root make -C ${LIBBPF_SRC}/libbpf/src install
        INSTALL_COMMAND ""
        UPDATE_COMMAND ""
    )
    message(STATUS "Using bundled libbpf: include'${LIBBPF_INCLUDE}', lib: ${LIBBPF_LIB}")
endif()

include_directories(${LIBBPF_INCLUDE})
