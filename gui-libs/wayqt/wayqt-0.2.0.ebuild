# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="A Qt-based wrapper for various wayland protocols"
HOMEPAGE="https://gitlab.com/desktop-frameworks/wayqt"
SRC_URI="https://gitlab.com/desktop-frameworks/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt6"

DEPEND="
	!qt6? (
		dev-qt/qtcore:5=
		dev-qt/qtgui:5=[wayland]
		dev-qt/qtwayland:5=
	)
	qt6? (
		dev-qt/qtbase:6=[gui,wayland]
		dev-qt/qtwayland:6=
	)
"
RDEPEND="${DEPEND}"
BDEPENDS="
	virtual/pkgconfig
"

S="${WORKDIR}/${PN}-v${PV}"

src_configure() {
	local emesonargs=(
		-Duse_qt_version=$(usex qt6 qt6 qt5)
	)
	meson_src_configure
}
