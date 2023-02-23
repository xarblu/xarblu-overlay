# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The banana cursor"
HOMEPAGE="https://github.com/ful1e5/banana-cursor"
SRC_URI="https://github.com/ful1e5/${PN}/releases/download/v${PV}/Banana.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/icons
	doins -r  Banana
}
