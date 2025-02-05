# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KFMIN="6.0"
SLOT="6"
ECM_NONGUI="true"

inherit ecm

MY_PN="KDE-Rounded-Corners"

DESCRIPTION="Rounds the corners of your windows in KDE Plasma 6"
HOMEPAGE="https://github.com/matinlotfali/KDE-Rounded-Corners"
SRC_URI="https://github.com/matinlotfali/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
KEYWORDS="~amd64"

DEPEND="
	>=kde-frameworks/kcmutils-${KFMIN}:${SLOT}=
	>=kde-frameworks/kconfigwidgets-${KFMIN}:${SLOT}=
	>=kde-frameworks/ki18n-${KFMIN}:${SLOT}=
	kde-plasma/kwin:${SLOT}=
	media-libs/libepoxy
	x11-libs/libxcb
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"
