# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

MY_PN=${PN^}

DESCRIPTION="Cut, copy, and paste anything, anywhere, all from the terminal"
HOMEPAGE="https://getclipboard.app"
SRC_URI="https://github.com/Slackadays/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="debug wayland X"

DEPEND="
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
	)
	X? ( x11-libs/libX11 )
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_PN}-${PV}"

src_configure() {
		local mycmakeargs=(
			-DNO_WAYLAND=$(usex wayland NO YES)
			-DNO_X11=$(usex X NO YES)
		)
		if ! use debug; then
			append-cflags -DNDEBUG
			append-cxxflags -DNDEBUG
			mycmakeargs+=( -Wno-dev )
		fi
		cmake_src_configure
}

src_install() {
	cmake_src_install

	# fix multilib-strict
	if [[ $(get_libdir) != "lib" ]]; then
		einfo "fixing multilib-strict path..."
		mv ${ED}/usr/lib ${ED}/usr/$(get_libdir) || die "fixing multilib-strict path failed"
	fi
}
