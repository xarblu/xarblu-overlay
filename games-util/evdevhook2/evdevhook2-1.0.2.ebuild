# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit vala meson

DESCRIPTION="Cemuhook UDP server for devices with modern Linux drivers"
HOMEPAGE="https://github.com/v1993/evdevhook2"

GCEMUHK_V="91ef61cca809f5f3b9fa6e5304aba284a56c06dc"

SRC_URI="
	https://github.com/v1993/evdevhook2/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/v1993/gcemuhook/archive/${GCEMUHK_V}.tar.gz -> gcemuhook-${GCEMUHK_V}.tar.gz
"

IUSE="battery"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	>=dev-libs/glib-2.50:=
	>=dev-libs/libgee-0.20:=
	>=sys-libs/zlib-1.2:=
"
RDEPEND="
	${DEPEND}
	virtual/libudev
	dev-libs/libevdev
	battery? ( sys-power/upower )
"
BDEPEND="
	${DEPEND}
	$(vala_depend)
"

src_prepare() {
	default
	vala_setup

	# QA: install docs via dodoc
	sed -i -e '/.*ExampleConfig\.ini.*/d' meson.build || die "sed failed"

	# symlink submodule
	ln -sfv "${WORKDIR}/gcemuhook-${GCEMUHK_V}" "${S}/subprojects/gcemuhook"
}

src_install() {
	meson_src_install
	dodoc ExampleConfig.ini
}

pkg_postinst() {
	elog "An example config was installed to /usr/share/doc/${P}/ExampleConfig.ini"
}
