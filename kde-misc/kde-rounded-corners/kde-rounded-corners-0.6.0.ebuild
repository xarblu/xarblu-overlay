# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KF_MIN="5.240"
SLOT="6"
ECM_NONGUI="true"

inherit ecm

MY_PN="KDE-Rounded-Corners"

DESCRIPTION="Rounds the corners of your windows in KDE Plasma 6"
HOMEPAGE="https://github.com/matinlotfali/KDE-Rounded-Corners"
SRC_URI="https://github.com/matinlotfali/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-qt/qtbase:${SLOT}=[gui,network,opengl,widgets,xml]
	dev-qt/qtdbus:${SLOT}=
	>=kde-frameworks/kconfig-${KF_MIN}:${SLOT}=
	>=kde-frameworks/kconfigwidgets-${KF_MIN}:${SLOT}=
	>=kde-frameworks/kcoreaddons-${KF_MIN}:${SLOT}=
	>=kde-frameworks/kglobalaccel-${KF_MIN}:${SLOT}=
	>=kde-frameworks/kwindowsystem-${KF_MIN}:${SLOT}=
	>=kde-frameworks/kcmutils-${KF_MIN}:${SLOT}=
	kde-plasma/kwin:${SLOT}=
	media-libs/libepoxy
	x11-libs/libxcb
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	# force Qt6
	sed -i -e '/find_package(QT NAMES/s/Qt5//' CMakeLists.txt || die "sed failed"

	default
	cmake_src_prepare
}

