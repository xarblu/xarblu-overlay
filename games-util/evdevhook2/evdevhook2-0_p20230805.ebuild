# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit vala meson

DESCRIPTION="Cemuhook UDP server for devices with modern Linux drivers"
HOMEPAGE="https://github.com/v1993/evdevhook2"

declare -A commit=(
	[main]="ff274749ab4ab88e68a4eb98ed92a3e65e2fcf85"
	[gcemuhook]="acde07238a16c78e39f4aee241ab7ae53b46cde6"
)

SRC_URI="
	https://github.com/v1993/evdevhook2/archive/${commit[main]}.tar.gz -> ${P}.tar.gz
	https://github.com/v1993/gcemuhook/archive/${commit[gcemuhook]}.tar.gz -> gcemuhook-${commit[gcemuhook]}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	>=dev-libs/glib-2.50
	>=dev-libs/libgee-0.20
	>=sys-libs/zlib-1.2
"
RDEPEND="${DEPEND}"
BDEPEND="
	${DEPEND}
	$(vala_depend)
"

S="${WORKDIR}/${PN}-${commit[main]}"

src_prepare() {
	default
	vala_setup

	# symlink submodule
	rmdir "${S}/subprojects/gcemuhook"
	ln -sfv "${WORKDIR}/gcemuhook-${commit[gcemuhook]}" "${S}/subprojects/gcemuhook"
}

src_install() {
	meson_src_install
	einstalldocs

	# install example config
	insinto "/usr/share/${PN}/"
	doins ExampleConfig.ini
}

pkg_postinst() {
	elog "An example config was installed to /usr/share/evdevhook2/ExampleConfig.ini"
}
