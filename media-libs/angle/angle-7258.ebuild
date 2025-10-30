# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit ninja-utils toolchain-funcs

GIT_SRC_SPECS=(
	# main
	# https://github.com/LadybirdBrowser/ladybird/blob/master/Meta/CMake/flatpak/org.ladybird.Ladybird.json
	'https://chromium.googlesource.com/angle/angle;7ab02e1d49a649adaba62b8a7fdfabf8144b313f;angle'
	# deps
	# curl https://raw.githubusercontent.com/LadybirdBrowser/ladybird/refs/heads/master/Meta/CMake/flatpak/angle/angle-sources.json | jq -r '.[]| "    '"'"'" + .url + ";" + .commit + ";" + .dest + "'"'"'"'
	# ...and fix broken entries because some use branches :P
    'https://chromium.googlesource.com/chromium/src/build.git;169fcf699b64d2d5e75a391beaec8a7ad6e41a7f;angle/build'
    'https://chromium.googlesource.com/chromium/src/testing;0d5210a4b1978e7e2c6b8623c719dff0a0994a8f;angle/testing'
    'https://chromium.googlesource.com/chromium/src/third_party/abseil-cpp;e3d58ba1a2a04f85225c3c04fa4603bb64399b2c;angle/third_party/abseil-cpp'
    'https://chromium.googlesource.com/external/github.com/ARM-software/astc-encoder;2319d9c4d4af53a7fc7c52985e264ce6e8a02a9b;angle/third_party/astc-encoder/src'
    'https://chromium.googlesource.com/external/github.com/KhronosGroup/EGL-Registry;7dea2ed79187cd13f76183c4b9100159b9e3e071;angle/third_party/EGL-Registry/src'
    'https://chromium.googlesource.com/chromiumos/third_party/libdrm.git;ad78bb591d02162d3b90890aa4d0a238b2a37cde;angle/third_party/libdrm/src'
    'https://chromium.googlesource.com/chromium/src/third_party/jsoncpp;f62d44704b4da6014aa231cfc116e7fd29617d2a;angle/third_party/jsoncpp'
    'https://chromium.googlesource.com/external/github.com/open-source-parsers/jsoncpp.git;ca98c98457b1163cca1f7d8db62827c115fec6d1;angle/third_party/jsoncpp/source'
    'https://chromium.googlesource.com/external/github.com/KhronosGroup/OpenGL-Registry;200cea4030cb49d3e40677379e6368a5f0e8c27b;angle/third_party/OpenGL-Registry/src'
    'https://chromium.googlesource.com/external/github.com/Tencent/rapidjson;781a4e667d84aeedbeb8184b7b62425ea66ec59f;angle/third_party/rapidjson/src'
    'https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers;2a611a970fdbc41ac2e3e328802aed9985352dca;angle/third_party/spirv-headers/src'
    'https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools;108b19e5c6979f496deffad4acbe354237afa7d3;angle/third_party/spirv-tools/src'
    'https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Headers;10739e8e00a7b6f74d22dd0a547f1406ff1f5eb9;angle/third_party/vulkan-headers/src'
    'https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Loader;c8a2c8c9164a58ce71c1c77104e28e8de724539e;angle/third_party/vulkan-loader/src'
    'https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Tools;e3fc64396755191b3c51e5c57d0454872e7fa487;angle/third_party/vulkan-tools/src'
    'https://chromium.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator;56300b29fbfcc693ee6609ddad3fdd5b7a449a21;angle/third_party/vulkan_memory_allocator'
    'https://chromium.googlesource.com/chromium/src/third_party/zlib;4028ebf8710ee39d2286cb0f847f9b95c59f84d8;angle/third_party/zlib'
)

# https://github.com/LadybirdBrowser/ladybird/blob/master/Meta/CMake/flatpak/org.ladybird.Ladybird.json
FILE_SRC_SPECS=(
	'https://storage.googleapis.com/angle-glslang-validator/de8679c3e2f15291ba4f5c32eebc954ce78bf39c;angle/tools/glslang/glslang_validator'
	'https://storage.googleapis.com/angle-flex-bison/36625019a2442ac8efc92c32e1d61bd3f450b7ab;angle/tools/flex-bison/linux/bison'
	'https://storage.googleapis.com/angle-flex-bison/3c9694c62a4ad0d1f95b45bb748855c3688c923e;angle/tools/flex-bison/linux/flex'
	'https://raw.githubusercontent.com/LadybirdBrowser/ladybird/refs/heads/master/Meta/CMake/flatpak/angle/gclient_args.gni;angle/build/config/gclient_args.gni'
)

DESCRIPTION="OpenGL ES implementation (for Ladybird)"
HOMEPAGE="https://chromium.googlesource.com/angle/angle"

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

S="${WORKDIR}/${PN}"

gen_src_uri() {
	local spec repo commit dest
	for spec in "${GIT_SRC_SPECS[@]}"; do
		IFS=";" read -r repo commit dest <<<"${spec}"
		[[ -z "${repo}" ]] && die "Spec ${spec} is missing repo"
		[[ -z "${commit}" ]] && die "Spec ${spec} is missing commit"
		[[ -z "${dest}" ]] && die "Spec ${spec} is missing dest"
		SRC_URI+=" ${repo}/+archive/${commit}.tar.gz -> ${P}-${dest////_}.tar.gz "
	done

	local spec url dest
	for spec in "${FILE_SRC_SPECS[@]}"; do
		IFS=";" read -r url dest <<<"${spec}"
		[[ -z "${url}" ]] && die "Spec ${spec} is missing url"
		[[ -z "${dest}" ]] && die "Spec ${spec} is missing dest"
		SRC_URI+=" ${url} -> ${P}-${dest////_} "
	done
}
gen_src_uri

src_unpack() {
	local spec repo commit dest
	for spec in "${GIT_SRC_SPECS[@]}"; do
		IFS=";" read -r repo commit dest <<<"${spec}"
		mkdir -p "${dest}" || die
		pushd "${dest}" >/dev/null || die
		unpack "${P}-${dest////_}.tar.gz"
		popd >/dev/null || die
	done

	local spec url dest
	for spec in "${FILE_SRC_SPECS[@]}"; do
		IFS=";" read -r url dest <<<"${spec}"
		mkdir -p "${dest%/*}" || die
		cp --dereference --verbose \
			"${DISTDIR}/${P}-${dest////_}" "${dest}" || die
	done
}

BUILD_DIR="${S}_build"

src_configure() {
	local is_clang=false
	# clang doesn't work for now
	#tc-is-clang && is_clang=true

	# FIXME respect *FLAGS
	# FIXME vulkan
	local -a gn_args=(
		"is_clang=${is_clang}"
		'is_official_build=true'
		'is_component_build=true'
		'is_debug=false'
		'angle_build_tests=false'
		'angle_enable_abseil=true'
		'angle_enable_renderdoc=false'
		'angle_enable_swiftshader=false'
		'angle_enable_vulkan=true'
		'angle_enable_wgpu=false'
		'angle_expose_non_conformant_extensions_and_versions=true'
		'angle_use_wayland=true'
		'angle_use_x11=false'
		'build_angle_deqp_tests=false'
		'treat_warnings_as_errors=false'
		'use_custom_libcxx=false'
		'use_safe_libstdcxx=true'
		'use_siso=false'
		'use_sysroot=false'
		'chrome_pgo_phase=0'
		'is_cfi=false'
	)

	gn gen "${BUILD_DIR}" --args="${gn_args[*]}" || die
}

src_compile() {
	eninja -C "${BUILD_DIR}"

	einfo "Preparing header files"
	pushd include >/dev/null || die
		find . -name '*.h' -exec install -Dm644 {} "${BUILD_DIR}/include/${PN}/{}" \;
	popd || die
}

src_install() {
	# libs
	local -a libs=(
		libEGL.so
		libEGL_vulkan_secondaries.so
		libGLESv1_CM.so
		libGLESv2.so
		libGLESv2_vulkan_secondaries.so
		libGLESv2_with_capture.so
		libchrome_zlib.so
		libfeature_support.so
		libthird_party_abseil-cpp_absl.so
	)
	insinto "/usr/$(get_libdir)/angle"
	local lib
	for lib in "${libs[@]}"; do
		doins "${BUILD_DIR}/${lib}"
	done

	# includes
	doheader -r "${BUILD_DIR}/include/${PN}"

	# pkgconfig
	insinto "/usr/$(get_libdir)/pkgconfig"
	newins - angle.pc <<EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${prefix}/$(get_libdir)/angle
includedir=\${prefix}/include
Name: angle
Description: A conformant OpenGL ES implementation for Windows, Mac, Linux, iOS and Android.
URL: https://angleproject.org/
Version: ${PV}
Libs: -L\${libdir} -lEGL -lGLESv2
Cflags: -I\${includedir}/angle
EOF
}
