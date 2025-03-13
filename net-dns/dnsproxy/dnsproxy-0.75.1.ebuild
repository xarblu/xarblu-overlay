# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support"
HOMEPAGE="https://github.com/AdguardTeam/dnsproxy"

SRC_URI="
	https://github.com/AdguardTeam/dnsproxy/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/xarblu/xarblu-overlay/releases/download/distfiles/${P}-deps.tar.xz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"

BDEPEND=">=dev-lang/go-1.24.1:="

src_compile() {
	# from ./scripts/make/go-build.sh
	local version_pkg='github.com/AdguardTeam/dnsproxy/internal/version'
	local ldflags o_flags
	ldflags="-s -w"
	ldflags="${ldflags} -X ${version_pkg}.branch=none"
	ldflags="${ldflags} -X ${version_pkg}.committime=none"
	ldflags="${ldflags} -X ${version_pkg}.revision=none"
	ldflags="${ldflags} -X ${version_pkg}.version=${PV}"
	o_flags="-o=${PN}"
	ego build \
		--ldflags="${ldflags}" \
		--trimpath \
		"${o_flags}"
}

src_install() {
	dobin "${PN}"
	insinto /etc/dnsproxy
	newins config.yaml.dist config.yaml
	systemd_newunit "${FILESDIR}"/dnsproxy.service-r1 dnsproxy.service
}
