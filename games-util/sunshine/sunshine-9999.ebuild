# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Host for Moonlight Streaming Client"
HOMEPAGE="https://github.com/loki-47-6F-64/sunshine"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/loki-47-6F-64/sunshine.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/loki-47-6F-64/sunshine/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="cuda kms vaapi wayland x11"

DEPEND="
		dev-libs/openssl
		>=media-video/ffmpeg-4.3
		media-sound/pulseaudio
		media-libs/opus
		dev-libs/libevdev
		cuda? (
			dev-util/nvidia-cuda-sdk
			dev-util/nvidia-cuda-toolkit
		)
		kms? (
			x11-libs/libdrm
			sys-libs/libcap
		)
		vaapi? (
			>=media-video/ffmpeg-4.3[vaapi]
		)
		wayland? (
			dev-libs/wayland
		)
		x11? (
			x11-libs/libXtst
			x11-libs/libX11
			x11-libs/libXrandr
			x11-libs/libXfixes
			x11-libs/libxcb
		)
"
RDEPEND="${DEPEND}"
BDEPEND="
		dev-util/cmake
		>=sys-devel/gcc-10
		dev-libs/boost[threads]
"

#PATCHES=("${FILESDIR}"/allow-dynamic-boost-libs.patch)

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_fetch
		git-r3_checkout
	else
		default
	fi
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_C_COMPILER=gcc
		-DCMAKE_CXX_COMPILER=g++
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	cmake_src_install
}









