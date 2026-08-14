# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

MY_PN="ProtonPlus"
MY_P="${MY_PN}-${PV}"

# vala + meson for src_*
# gnome2 for pkg_{preinst,postinst,postrm}
inherit vala gnome2 meson

DESCRIPTION="A modern compatibility tools manager"
HOMEPAGE="https://github.com/Vysp3r/ProtonPlus"
SRC_URI="https://github.com/Vysp3r/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	virtual/pkgconfig
	dev-util/desktop-file-utils
	$(vala_depend)
"
DEPEND="
	>=gui-libs/libadwaita-1.6
	>=media-libs/libsdl3-3.2.0
	app-arch/libarchive
	dev-libs/appstream
	dev-libs/appstream-glib
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee:0.8
	dev-util/desktop-file-utils
	gui-libs/gtk:4
	net-libs/libsoup:3.0
	sys-devel/gettext
	x11-libs/cairo
	x11-libs/libnotify
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/0.6.4-fix-clang-control-char.patch"
	"${FILESDIR}/0.6.4-fix-ProtonPlusCpuFeatureProbe-redefinition.patch"
)

src_prepare() {
	vala_setup
	default
}
