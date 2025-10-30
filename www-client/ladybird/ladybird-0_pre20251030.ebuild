# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit cmake python-any-r1

LADYBIRD_COMMIT="991ab62dd71c980e79812546316ed5252b42a780"
# https://github.com/publicsuffix/list/commits/main/
PUBLIC_SUFFIX_COMMIT="8e3b7b7885c7c198a66df3df8c049c066d7c1a6b"

DESCRIPTION="Ladybird Web Browser"
HOMEPAGE="https://ladybird.org/"
SRC_URI="
	https://github.com/LadybirdBrowser/ladybird/archive/${LADYBIRD_COMMIT}.tar.gz
		-> ${P}.gh.tar.gz
	https://raw.githubusercontent.com/publicsuffix/list/${PUBLIC_SUFFIX_COMMIT}/public_suffix_list.dat
		-> ${P}-public_suffix_list.dat
"
S="${WORKDIR}/${PN}-${LADYBIRD_COMMIT}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="
	dev-lang/nasm
	${PYTHON_DEPS}
"
DEPEND="
	dev-cpp/simdutf
	dev-db/sqlite:3=
	dev-libs/icu
	dev-libs/libdispatch
	dev-libs/openssl
	dev-qt/qtbase:6=[widgets]
	media-libs/angle
	media-libs/fontconfig
	media-libs/libsdl3
	media-libs/skia
	net-misc/curl
	sys-libs/zlib
"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack "${P}.gh.tar.gz"

	mkdir -p "${T}/caches/PublicSuffix" || die
	cp "${DISTDIR}/${P}-public_suffix_list.dat" \
		"${T}/caches/PublicSuffix/public_suffix_list.dat" || die
}

src_configure() {
	local mycmakeargs=(
		-DLADYBIRD_CACHE_DIR="${T}/caches"
		-DENABLE_NETWORK_DOWNLOADS=OFF
	)
	cmake_src_configure
}
