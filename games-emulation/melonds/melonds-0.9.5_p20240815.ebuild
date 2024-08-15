# Copyright 2019-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="melonDS"
MY_P="${MY_PN}-${PV}"

[[ "${PV}" == *_p* ]] && COMMIT="0e6235a7c4d3e69940a6deae158a5a91dfbfa612"

inherit cmake flag-o-matic readme.gentoo-r1 toolchain-funcs xdg

DESCRIPTION="Nintendo DS emulator, sorta"
HOMEPAGE="https://melonds.kuribo64.net https://github.com/melonDS-emu/melonDS"

if [[ "${PV}" == *9999* ]] ; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/Arisotura/${MY_PN}.git"
else
	SRC_URI="
		https://github.com/melonDS-emu/${MY_PN}/archive/${COMMIT}.tar.gz
			-> ${MY_P}.tar.gz
	"
	S="${WORKDIR}/${MY_PN}-${COMMIT}"

	KEYWORDS="~amd64"
fi

LICENSE="BSD-2 GPL-2 GPL-3 Unlicense"
SLOT="0"
IUSE="+jit +opengl qt6 wayland"

RDEPEND="
	app-arch/libarchive
	app-arch/zstd
	media-libs/libsdl2[sound,video]
	net-libs/enet
	net-libs/libpcap
	net-libs/libslirp
	virtual/opengl
	x11-libs/libX11
	!qt6? (
		dev-qt/qtcore:5=
		dev-qt/qtgui:5=
		dev-qt/qtmultimedia:5=
		dev-qt/qtnetwork:5=
		dev-qt/qtsvg:5=
		dev-qt/qtwidgets:5=
	)
	qt6? (
		dev-qt/qtbase:6=[gui,widgets,network,opengl]
		dev-qt/qtmultimedia:6=
		dev-qt/qtsvg:6=
	)
	wayland? ( dev-libs/wayland )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	wayland? ( kde-frameworks/extra-cmake-modules:0 )
"

# used for JIT recompiler
QA_EXECSTACK="usr/bin/melonDS"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="You need the following files in order to run melonDS:
- bios7.bin
- bios9.bin
- firmware.bin
- romlist.bin
Place them in ~/.config/melonDS
Those files can be extracted from devices or found somewhere on the Internet ;-)"

src_prepare() {
	filter-lto
	append-flags -fno-strict-aliasing

	cmake_src_prepare
}

src_configure() {
	local -a mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DENABLE_JIT=$(usex jit)
		-DENABLE_OGLRENDERER=$(usex opengl)
		-DENABLE_WAYLAND=$(usex wayland)
		-DUSE_QT6=$(usex qt6)
	)
	cmake_src_configure
}

src_compile() {
	tc-export AR
	cmake_src_compile
}

src_install() {
	readme.gentoo_create_doc
	cmake_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
	readme.gentoo_print_elog
}
