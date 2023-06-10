# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Automatically (un)mount network filesystems"
HOMEPAGE="https://github.com/xarblu/netdev-automount"
SRC_URI="https://github.com/xarblu/netdev-automount/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+networkmanager"

DEPEND="
	>=dev-lang/python-3.11
	networkmanager? ( net-misc/networkmanager )
"
RDEPEND="${DEPEND}"

src_install() {
	dobin ${PN}
	if use networkmanager; then
		dosym "${EPREFIX}/usr/bin/${PN}" "/usr/lib/NetworkManager/dispatcher.d/30-${PN}"
		dosym "${EPREFIX}/usr/bin/${PN}" "/usr/lib/NetworkManager/dispatcher.d/pre-down.d/30-${PN}"
	fi
}
