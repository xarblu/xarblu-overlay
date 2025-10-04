# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

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

BDEPEND=">=dev-lang/go-1.25.1:="

QA_PRESTRIPPED="/usr/bin/dnsproxy"

src_compile() {
	# from ./scripts/make/go-build.sh
	local version_pkg='github.com/AdguardTeam/dnsproxy/internal/version'
	local ldflags
	ldflags="-s -w"
	ldflags+=" -X ${version_pkg}.version=${PV}"
	export CGO_ENABLED=0
	ego build \
		--ldflags="${ldflags}" \
		--race=0 \
		--trimpath \
		-o="${PN}"
}

src_install() {
	dobin "${PN}"
	insinto /etc/dnsproxy
	newins config.yaml.dist config.yaml
	systemd_newunit "${FILESDIR}"/dnsproxy.service-r1 dnsproxy.service
}
