# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Terminfo for WezTerm"
HOMEPAGE="https://wezfurlong.org/wezterm/"

MY_PN="${PN%%-*}"
if [[ "${PV}" == *_pre* ]]; then
	MY_PV="e3cd2e93d0ee5f3af7f3fe0af86ffad0cf8c7ea8"
	MY_P="${MY_PN}-${MY_PV}"
	SRC_URI="
		https://github.com/wez/${MY_PN}/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz
		"
else
	MY_PV="$(ver_rs 1 -)-5046fc22"
	MY_P="${MY_PN}-${MY_PV}"
	SRC_URI="
		https://github.com/wez/${MY_PN}/releases/download/${MY_PV}/${MY_P}-src.tar.gz
		"
fi
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT=test

BDEPENDS="sys-libs/ncurses"

S="${WORKDIR}/${MY_P}"

src_compile() { :; }

src_install() {
	dodir /usr/share/terminfo
	tic -xo "${ED}"/usr/share/terminfo termwiz/data/wezterm.terminfo || die
}
