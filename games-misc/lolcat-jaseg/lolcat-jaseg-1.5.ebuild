# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="High-performance implementation of lolcat"
HOMEPAGE="https://github.com/jaseg/lolcat"
SRC_URI="https://github.com/jaseg/lolcat/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/lolcat-${PV}"

LICENSE="WTFPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# block to avoid file collisions
RDEPEND="!games-misc/lolcat"

src_install() {
	dodir /usr/bin
	emake DESTDIR="${ED}/usr/bin" install
}
