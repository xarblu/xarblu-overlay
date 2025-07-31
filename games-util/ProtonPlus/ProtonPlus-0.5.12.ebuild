# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# vala + meson for src_*
# gnome2 for pkg_{preinst,postinst,postrm}
inherit vala gnome2 meson

DESCRIPTION="A modern compatibility tools manager"
HOMEPAGE="https://github.com/Vysp3r/ProtonPlus"
SRC_URI="https://github.com/Vysp3r/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="$(vala_depend)"
DEPEND="
	>=gui-libs/libadwaita-1.5
	app-arch/libarchive
	dev-libs/appstream-glib
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee:0.8
	dev-util/desktop-file-utils
	gui-libs/gtk:4
	net-libs/libsoup:3.0
	sys-devel/gettext
"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	vala_setup
}
