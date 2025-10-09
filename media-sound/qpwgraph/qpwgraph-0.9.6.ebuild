# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

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

IUSE="+alsa +trayicon"

DEPEND="
	dev-qt/qtbase:6=[gui,widgets,xml]
	dev-qt/qtsvg:6=
	media-video/pipewire:=
	alsa? ( media-libs/alsa-lib )
	trayicon? ( dev-qt/qtbase:6=[network] )
"
RDEPEND="${DEPEND}"

src_prepare() {
	# remove "hardcoded" platform
	# I personally have never had issues on Wayland
	# so just let Qt figure out the correct platform
	sed -i -e '/^Exec=/s/-platform xcb //' \
		src/appdata/org.rncbc.qpwgraph.desktop || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCONFIG_ALSA_MIDI="$(usex alsa)"
		-DCONFIG_SYSTEM_TRAY="$(usex trayicon)"
		-DCONFIG_QT6=yes
	)

	cmake_src_configure
}
