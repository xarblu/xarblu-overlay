# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit ninja-utils toolchain-funcs

DESCRIPTION="2D graphic library for drawing Text, Geometries, and Images"
HOMEPAGE="https://skia.org/"
SRC_URI="
	https://skia.googlesource.com/skia.git/+archive/refs/heads/chrome/m${PV}.tar.gz
		-> ${P}.tar.gz
"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="
	dev-build/gn
"
DEPEND="
	dev-libs/icu
	dev-util/vulkan-headers
	media-libs/fontconfig
	media-libs/harfbuzz
	sys-libs/zlib
"
RDEPEND="${DEPEND}"

src_unpack() {
	mkdir "${S}" || die
	pushd "${S}" >/dev/null || die
	unpack "${P}.tar.gz"
	popd >/dev/null || die
}

BUILD_DIR="${S}_build"

src_configure() {
	# FIXME respect *FLAGS
	# FIXME vulkan
	local -a gn_args=(
		"cc=\"$(tc-getCC)\""
		"cxx=\"$(tc-getCXX)\""
		'is_official_build=true'
    	'is_component_build=true'
    	'is_debug=false'
    	'skia_use_dng_sdk=false'
    	'skia_use_wuffs=false'
    	'skia_use_zlib=true'
    	'skia_use_system_zlib=true'
    	'skia_use_harfbuzz=true'
    	#'skia_use_vulkan=true'
    	'skia_use_fontconfig=true'
    	'skia_use_icu=true'
    	'skia_use_system_icu=true'
    	'extra_cflags=["-DSK_USE_EXTERNAL_VULKAN_HEADERS","-Wno-psabi"]'
    	'extra_cflags_cc=["-DSKCMS_API=__attribute__((visibility(\"default\")))"]'
	)

	gn gen "${BUILD_DIR}" --args="${gn_args[*]}" || die
}

src_compile() {
	eninja -C "${BUILD_DIR}" :skia :modules

	einfo "Preparing header files"
	pushd include >/dev/null || die
		find . -name '*.h' -exec install -Dm644 {} "${BUILD_DIR}/include/skia/{}" \;
	popd || die

	pushd modules >/dev/null || die
		find . -name '*.h' -exec install -Dm644 {} "${BUILD_DIR}/include/skia/modules/{}" \;
	popd || die

	# Some skia includes are assumed to be under an include sub directory by
	# other includes
	local file
	# shellcheck disable=SC2013
	for file in $(grep -rl '#include "include/' "${BUILD_DIR}/include/skia"); do
		sed -i -e 's|#include "include/|#include "|g' "$file" || die "fixing include failed for ${file}"
	done
}

src_install() {
	# libs
	dolib.a "${BUILD_DIR}"/*.a
	dolib.so "${BUILD_DIR}"/*.so

	# includes
	doheader -r "${BUILD_DIR}/include/skia"

	# pkgconfig
	insinto "/usr/$(get_libdir)/pkgconfig"
	newins - skia.pc <<EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${prefix}/$(get_libdir)
includedir=\${prefix}/include/skia
Name: skia
Description: 2D graphic library for drawing text, geometries and images.
URL: https://skia.org/
Version: ${PV}
Libs: -L\${libdir} -lskia -lskcms
Cflags: -I\${includedir}
EOF
}
