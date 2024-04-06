# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit fcaps systemd

MY_PN="${PN/-bin/}"

DESCRIPTION="Network-wide ads & trackers blocking DNS server"
HOMEPAGE="https://github.com/AdguardTeam/AdGuardHome"

SRC_URI_BASE="https://github.com/AdguardTeam/${MY_PN}/releases/download/v${PV}/"
SRC_URI="
	amd64? ( ${SRC_URI_BASE}/${MY_PN}_linux_amd64.tar.gz -> ${P}-amd64.tar.gz )
	arm? ( ${SRC_URI_BASE}/${MY_PN}_linux_armv7.tar.gz -> ${P}-arm.tar.gz )
	arm64? ( ${SRC_URI_BASE}/${MY_PN}_linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
	ppc64? ( ${SRC_URI_BASE}/${MY_PN}_linux_ppc64le.tar.gz -> ${P}-ppc64.tar.gz )
	x86? ( ${SRC_URI_BASE}/${MY_PN}_linux_386.tar.gz -> ${P}-x86.tar.gz )
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm ~arm64 ~ppc64 ~x86"

RDEPEND="
	acct-user/adguardhome
	acct-group/adguardhome
"

S="${WORKDIR}/${MY_PN}"

DOCS=( {CHANGELOG,README}.md )
QA_PREBUILT="opt/adguardhome/AdGuardHome"
FILECAPS=( 'cap_net_bind_service=+eip cap_net_raw=+eip' opt/adguardhome/AdGuardHome )

src_install() {
	# install binary and wrapper
	exeinto /opt/adguardhome
	doexe AdGuardHome
	exeinto /usr/bin
	newexe "${FILESDIR}/wrapper.sh" AdGuardHome

	# install dirs
	diropts -o adguardhome -g adguardhome
	# /var/lib/adguardhome handled by acct-user/adguardhome
	keepdir /var/log/adguardhome /etc/adguardhome

	# install services
	newinitd "${FILESDIR}"/adguardhome.initd adguardhome
	newconfd "${FILESDIR}"/adguardhome.confd adguardhome
	systemd_dounit "${FILESDIR}"/adguardhome.service
	einstalldocs
}

pkg_postinst() {
	fcaps_pkg_postinst

	einfo "/usr/bin/AdGuardHome is a wrapper to ensure that certain flags are passed."
	einfo "Should you need the 'real' binary it's located at /opt/adguardhome/AdGuardHome."

	ewarn "The AdGuard Home service is set up to run as unprivileged user adguardhome."
	ewarn "Initial setup requires admin privileges."
	ewarn "Run AdGuardHome manually as root and follow the instructions to setup."
}
