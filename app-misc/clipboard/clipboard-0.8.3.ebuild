# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion cmake flag-o-matic

MY_PN=${PN^}

DESCRIPTION="Cut, copy, and paste anything, anywhere, all from the terminal"
HOMEPAGE="https://getclipboard.app"
SRC_URI="https://github.com/Slackadays/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="alsa debug lto wayland X"

DEPEND="
	alsa? ( media-libs/alsa-lib )
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
		-DNO_ALSA=$(usex alsa NO YES)
		-DNO_LTO=$(usex lto NO YES)
		-DNO_WAYLAND=$(usex wayland NO YES)
		-DNO_X11=$(usex X NO YES)
		-DCMAKE_INSTALL_LIBDIR=$(get_libdir)
	)
	if ! use debug; then
		append-cflags -DNDEBUG
		append-cxxflags -DNDEBUG
	fi
	cmake_src_configure
}

src_install() {
	# install shell completions
	newbashcomp documentation/completions/cb.bash cb
	dofishcomp documentation/completions/cb.fish
	newzshcomp documentation/completions/cb.zsh _cb

	# install manpage
	doman documentation/manpages/man.1

	# install desktop stuff
	domenu app.getclipboard.Clipboard.desktop
	doicon app.getclipboard.Clipboard.png
	insinto /usr/share/metainfo
	doins app.getclipboard.Clipboard.metainfo.xml

	# and the rest...
	cmake_src_install
}
