# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-cachyos}"

DESCRIPTION="ananicy-cpp-rules from CachyOS"
HOMEPAGE="https://github.com/CachyOS/ananicy-rules"
SRC_URI="https://github.com/CachyOS/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}/${MY_PN}-${PV}"

src_install() {
	insinto /etc/ananicy.d/
	doins -r \
		00-default \
		00-cgroups.cgroups \
		00-types.types \
		ananicy.conf
}
