# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="libevdev based DSU/cemuhook joystick server"
HOMEPAGE="https://github.com/v1993/evdevhook"

COMMIT="e82287051ceb78753193a0206c1fff048fe7987f"
SRC_URI="https://github.com/v1993/evdevhook/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-libs/libevdev
	virtual/libudev
	>=dev-cpp/glibmm-2.4
	>=dev-cpp/nlohmann_json-3.7.0
	sys-libs/zlib
"
RDEPEND="${DEPEND}"
BDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${COMMIT}"

src_install() {
	cmake_src_install

	#Install config_templates
	insinto /usr/share/evdevhook
	doins -r config_templates
}

pkg_postinst() {
	elog "Config templates were installed to /usr/share/evdevhook/config_templates"
}
