# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support"
HOMEPAGE="https://github.com/AdguardTeam/dnsproxy"

BASE_URI="https://github.com/AdguardTeam/dnsproxy/releases/download/v${PV}/"

ARCHMAPS="
	amd64:amd64
	x86:386
	arm:arm7
	arm64:arm64
	ppc64:ppc64le
"
src_uris() {
	local archmap genarch pkgarch
	for archmap in ${ARCHMAPS}; do
		genarch="${archmap%:*}"
		pkgarch="${archmap#*:}"
		SRC_URI+="
			${genarch}? (
				${BASE_URI}/dnsproxy-linux-${pkgarch}-v${PV}.tar.gz
					-> ${PN}-${genarch}-${PV}.tar.gz )
			"
	done
	# get default config for service
	SRC_URI+="https://raw.githubusercontent.com/AdguardTeam/dnsproxy/v${PV}/config.yaml.dist
				-> ${P}-config.yaml.dist"
}
src_uris

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"

QA_PREBUILT="usr/bin/dnsproxy"

S="${WORKDIR}"

src_install() {
	# figure out our arch name and install bin
	local archmap genarch pkgarch
	for archmap in ${ARCHMAPS}; do
		genarch="${archmap%:*}"
		pkgarch="${archmap#*:}"
		use ${genarch} && break
	done
	dobin "linux-${pkgarch}/${PN%-bin}"

	# default config and service
	insinto /etc/dnsproxy
	newins "${DISTDIR}/${P}-config.yaml.dist" config.yaml
	systemd_dounit "${FILESDIR}/dnsproxy.service"
}
