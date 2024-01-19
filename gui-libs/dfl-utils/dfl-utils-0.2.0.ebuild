# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Qt/C++ Utilities for DFL"
HOMEPAGE="https://gitlab.com/desktop-frameworks/utils"
SRC_URI="https://gitlab.com/desktop-frameworks/${PN#dfl-}/-/archive/v${PV}/${PN#dfl-}-v${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt6"

DEPEND="
	!qt6? (
		dev-qt/qtcore:5=
	)
	qt6? (
		dev-qt/qtbase:6=
	)
"
RDEPEND="${DEPEND}"
BDEPENDS="
	virtual/pkgconfig
"

S="${WORKDIR}/${PN#dfl-}-v${PV}"

src_configure() {
	local emesonargs=(
		-Duse_qt_version=$(usex qt6 qt6 qt5)
	)
	meson_src_configure
}
