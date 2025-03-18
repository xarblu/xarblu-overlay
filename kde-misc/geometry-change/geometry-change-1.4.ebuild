# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="kwin4_effect_${PN//-/_}"

DESCRIPTION="A KWin animation for windows moved or resized by programs or scripts"
HOMEPAGE="https://github.com/peterfajdiga/kwin4_effect_geometry_change"
SRC_URI="https://github.com/peterfajdiga/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	kde-plasma/kwin
"

S="${WORKDIR}/${MY_PN}-${PV}"

src_compile() { :; }

src_install() {
	insinto "/usr/share/kwin/effects/${MY_PN}"
	doins -r package/*
}
