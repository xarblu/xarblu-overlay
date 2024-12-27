# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="A PipeWire Graph Qt GUI Interface"
HOMEPAGE="https://gitlab.freedesktop.org/rncbc/qpwgraph"

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.freedesktop.org/rncbc/qpwgraph.git"
else
	SRC_URI="https://gitlab.freedesktop.org/rncbc/qpwgraph/-/archive/v${PV}/${PN}-v${PV}.tar.bz2 -> ${P}.tar.bz2"
	S="${WORKDIR}/${PN}-v${PV}"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2+"
SLOT="0"

IUSE="+alsa +trayicon wayland"

DEPEND="
	dev-qt/qtbase:6=[gui,widgets,xml]
	dev-qt/qtsvg:6=
	media-video/pipewire:=
	alsa? ( media-libs/alsa-lib )
	trayicon? ( dev-qt/qtbase:6=[network] )

"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		"-DCONFIG_ALSA_MIDI=$(usex alsa)"
		"-DCONFIG_SYSTEM_TRAY=$(usex trayicon)"
		"-DCONFIG_WAYLAND=$(usex wayland)"
		"-DCONFIG_QT6=yes"
	)

	cmake_src_configure
}
