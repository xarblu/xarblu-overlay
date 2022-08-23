# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Automatically move wireless interface into firewalld zone based on setting in relevant iwd network file"
HOMEPAGE="https://github.com/techhazard/iwd-firewalld-zone"
SRC_URI="https://github.com/techhazard/iwd-firewalld-zone/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}
	net-wireless/iwd
	net-firewall/firewalld
"
BDEPEND=""

PATCHES=( "${FILESDIR}/IWD_DIR-path.patch"
		  "${FILESDIR}/fix-exec-path.patch"
		  "${FILESDIR}/fix-get_wanted_zone.patch"
		  "${FILESDIR}/fix-long-SSID-hexencode.patch" )

src_install() {
	#Install main script
	dobin ${S}/bin/${PN}

	#Install the systemd units
	systemd_dounit ${S}/systemd/system/${PN}{.path,.target,@.service}
}

pkg_postinst() {
	elog "To enable ${PN} for a interface enable it via"
	elog "'systemctl enable ${PN}@<INTERFACE_NAME>.service'."
	elog ""
	elog "To set a zone for a network add 'FirewalldZone=<ZONE>'"
	elog "in the corresponding config file in '/var/lib/iwd'."
}
