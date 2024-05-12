# Copyright 2019-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="An innovative superfamily of fonts for code"
HOMEPAGE="https://monaspace.githubnext.com/"
SRC_URI="https://github.com/githubnext/monaspace/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+otf variable"

REQUIRED_USE="|| ( otf variable )"

DOCS=( README.md )

src_install() {
	FONT_SUFFIX=""
	FONT_S=( fonts/install )
	mkdir fonts/install || die
	if use otf; then
		FONT_SUFFIX+="${FONT_SUFFIX+ }otf"
		mv fonts/otf/* fonts/install || die
	fi
	if use variable; then
		FONT_SUFFIX+="${FONT_SUFFIX+ }ttf"
		mv fonts/variable/* fonts/install || die
	fi
	font_src_install
}
