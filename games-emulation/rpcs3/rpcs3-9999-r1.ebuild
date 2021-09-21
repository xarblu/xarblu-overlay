# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

inherit cmake git-r3 python-single-r1

DESCRIPTION="PlayStation 3 emulator"
HOMEPAGE="https://rpcs3.net/"
EGIT_REPO_URI="https://github.com/RPCS3/rpcs3"
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
	media-libs/libpng:*
	media-libs/openal
	media-video/ffmpeg
	dev-libs/pugixml
	dev-libs/xxhash
	pulseaudio? ( media-sound/pulseaudio )
	sys-libs/zlib
	virtual/opengl
	vulkan? ( media-libs/vulkan-loader )
	x11-libs/libX11
"

DEPEND="${RDEPEND}
	>=sys-devel/gcc-9
"

EGIT_SUBMODULES=(
	"*"
	"-3rdparty/FAudio"
	"-3rdparty/curl"
	"-3rdparty/ffmpeg"
	"-3rdparty/libpng"
	"-3rdparty/zlib"
	"-3rdparty/pugixml"
	"-3rdparty/xxHash"
)

CMAKE_BUILD_TYPE=RELWITHDEBINFO

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

src_prepare() {
	default

	sed -i \
		-e '/find_program(CCACHE_FOUND/d' \
		CMakeLists.txt
	sed -i \
		-e 's/DEBUG|RELEASE|RELWITHDEBINFO|MINSIZEREL/DEBUG|RELEASE|RELWITHDEBINFO|MINSIZEREL|GENTOO/' \
		llvm/CMakeLists.txt

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DBUILD_EXTERNAL=OFF
		-DUSE_PRECOMPILED_HEADERS=OFF
		-DUSE_NATIVE_INSTRUCTIONS=OFF
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
