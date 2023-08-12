# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

KF_MIN="5.78"

MY_PN="KDE-Rounded-Corners"

DESCRIPTION="Rounds the corners of your windows in KDE Plasma 5"
HOMEPAGE="https://github.com/matinlotfali/KDE-Rounded-Corners"
SRC_URI="https://github.com/matinlotfali/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-qt/qtgui:5=
	dev-qt/qtcore:5=
	dev-qt/qtdbus:5=
	dev-qt/designer:5=
	dev-qt/qtwidgets:5=
	dev-qt/qtx11extras:5=
	dev-qt/qtopengl:5=
	dev-qt/qtnetwork:5
	dev-qt/qtxml:5=
	>=kde-frameworks/kconfig-${KF_MIN}:5=
	>=kde-frameworks/kconfigwidgets-${KF_MIN}:5=
	>=kde-frameworks/kcoreaddons-${KF_MIN}:5=
	>=kde-frameworks/kglobalaccel-${KF_MIN}:5=
	>=kde-frameworks/kwindowsystem-${KF_MIN}:5=
	kde-plasma/kwin:5=
	media-libs/libepoxy
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	# fix link libs
	sed -i -e '/target_link_libraries.*/a \ \ \ \ Qt5::Widgets' src/CMakeLists.txt || die "sed failed"

	eapply_user
	cmake_src_prepare
}
