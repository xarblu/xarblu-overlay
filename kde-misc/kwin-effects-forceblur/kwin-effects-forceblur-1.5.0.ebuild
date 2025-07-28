# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KPMIN="6.4.0"
KFMIN="6.0.0"
QTMIN="6.6.0"

inherit ecm

DESCRIPTION="KWin Blur effect for KDE Plasma 6 to blur any window"
HOMEPAGE="https://github.com/taj-ny/kwin-effects-forceblur"
SRC_URI="https://github.com/taj-ny/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="6"
KEYWORDS="~amd64 ~x86"

DEPEND="
	>=dev-qt/qtbase-${QTMIN}:6=[dbus,gui,network,opengl,widgets,xml]
	>=dev-qt/qttools-${QTMIN}:6=
	>=kde-frameworks/kcmutils-${KFMIN}:6
	>=kde-frameworks/kconfig-${KFMIN}:6
	>=kde-frameworks/kconfigwidgets-${KFMIN}:6
	>=kde-frameworks/kcoreaddons-${KFMIN}:6
	>=kde-frameworks/kcrash-${KFMIN}:6
	>=kde-frameworks/kglobalaccel-${KFMIN}:6
	>=kde-frameworks/kguiaddons-${KFMIN}:6
	>=kde-frameworks/ki18n-${KFMIN}:6
	>=kde-frameworks/kio-${KFMIN}:6
	>=kde-frameworks/knotifications-${KFMIN}:6
	>=kde-frameworks/kservice-${KFMIN}:6
	>=kde-frameworks/kwidgetsaddons-${KFMIN}:6
	>=kde-frameworks/kwindowsystem-${KFMIN}:6
	>=kde-plasma/kdecoration-${KPMIN}:6
	>=kde-plasma/kwin-${KPMIN}:6
	media-libs/libepoxy
	x11-libs/libX11
	x11-libs/libxcb
"
RDEPEND="${DEPEND}"
