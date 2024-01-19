# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

MY_PN="QtGreet"

DESCRIPTION="Qt based greeter for greetd"
HOMEPAGE="https://gitlab.com/marcusbritanicus/QtGreet"
SRC_URI="https://gitlab.com/marcusbritanicus/${MY_PN}/-/archive/v${PV}/${MY_PN}-v${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+greetwl qt6"

DEPEND="
	gui-libs/dfl-applications[qt6?]
	gui-libs/dfl-ipc[qt6?]
	gui-libs/dfl-login1[qt6?]
	gui-libs/dfl-utils[qt6?]
	gui-libs/wayqt[qt6?]
	x11-libs/libxkbcommon[wayland]
	greetwl? (
		>=gui-libs/wlroots-0.17.0
	)
	!qt6? (
		dev-qt/qtcore:5=
		dev-qt/qtgui:5=[wayland]
		dev-qt/qtwidgets:5=
		dev-qt/qtdbus:5=
	)
	qt6? (
		dev-qt/qtbase:6=[gui,widgets,dbus,wayland]
	)
"
RDEPEND="
	${DEPEND}
	gui-libs/greetd
"

S="${WORKDIR}/${MY_PN}-v${PV}"

src_configure() {
	local emesonargs=(
		-Duse_qt_version=$(usex qt6 qt6 qt5)
		$(meson_use greetwl build_greetwl)
	)
	meson_src_configure
}

pkg_postinst() {
	if ! use greetwl; then
		ewar "Without USE greetwl you need to bring your own compositor."
	fi
}
