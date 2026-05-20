# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit cmake systemd

DESCRIPTION="Traccar Owntracks Proxy"
HOMEPAGE="https://github.com/xarblu/traccar-owntracks-proxy"
SRC_URI="
	https://github.com/xarblu/traccar-owntracks-proxy/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-cpp/cpp-httplib
	dev-cpp/nlohmann_json
"
RDEPEND="${DEPEND}"

src_install() {
	dobin "${BUILD_DIR}/src/${PN}"
	systemd_dounit "meta/${PN}.service"
}
