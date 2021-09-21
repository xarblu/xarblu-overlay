# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

inherit cmake git-r3 python-single-r1

DESCRIPTION="A Sony PlayStation 3 emulator"
HOMEPAGE="https://rpcs3.net/"
EGIT_REPO_URI="https://github.com/RPCS3/rpcs3.git"
EGIT_SUBMODULES=( "*" )

KEYWORDS="~amd64"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa discord-rpc joystick +llvm pulseaudio vulkan"

RDEPEND="
	>=dev-qt/qtcore-5.15.2
	>=dev-qt/qtdbus-5.15.2
	>=dev-qt/qtgui-5.15.2
	>=dev-qt/qtwidgets-5.15.2
	alsa? ( media-libs/alsa-lib )
	sys-devel/gdb
	joystick? ( dev-libs/libevdev )
	media-libs/glew:0
	media-libs/openal
	pulseaudio? ( media-sound/pulseaudio )
	virtual/opengl
	vulkan? ( media-libs/vulkan-loader )
	x11-libs/libX11
	net-misc/curl
	media-video/ffmpeg
	media-libs/libpng:*
	dev-libs/pugixml
	dev-libs/xxhash
	sys-libs/zlib
"

DEPEND="${RDEPEND}
	>=sys-devel/gcc-9
"

pkg_pretend() {
	if [[ "${MERGE_TYPE}" != "binary" ]]; then
		if tc-is-clang; then
			[[ $(clang-major-version) -lt 5 ]] && die "RPCS3 needs >=sys-devel/clang-5 to build"
		elif tc-is-gcc; then
			[[ $(gcc-major-version) -lt 8 ]] && die "RPCS3 needs >=sys-devel/gcc-8 to build"
		else
			die "RPCS3 needs  >=sys-devel/clang-5 or >=sys-devel/gcc-8 to build"
		fi
	fi
}

CMAKE_BUILD_TYPE=Release

src_configure() {
	local mycmakeargs=(
		-DUSE_NATIVE_INSTRUCTIONS=OFF
		-DUSE_PRECOMPILED_HEADERS=OFF
		-DBUILD_SHARED_LIBS=OFF
		-DBUILD_EXTERNAL=ON
		-DUSE_DISCORD_RPC=$(usex discord-rpc)
		-DUSE_LIBEVDEV=$(usex joystick)
		-DUSE_ALSA=$(usex alsa)
		-DUSE_PULSE=$(usex pulseaudio)
		-DUSE_VULKAN=$(usex vulkan)
		-DWITH_LLVM=$(usex llvm)
		-DBUILD_LLVM_SUBMODULE=ON
		-DUSE_FAUDIO=OFF
		-DUSE_SYSTEM_CURL=ON
		-DUSE_SYSTEM_FFMPEG=ON
		-DUSE_SYSTEM_LIBPNG=ON
		-DUSE_SYSTEM_PUGIXML=ON
		-DUSE_SYSTEM_XXHASH=ON
		-DUSE_SYSTEM_ZLIB=ON
	)
	cmake_src_configure
}
