# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )

inherit systemd python-r1

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
	dev-python/dbus-python
"
BDEPEND=""

PATCHES=( "${FILESDIR}/IWD_DIR-path.patch"
		  "${FILESDIR}/fix-get_wanted_zone.patch"
		  "${FILESDIR}/fix-long-SSID-hexencode.patch" )

src_install() {
	#Install main script
	dobin "${S}/bin/${PN}"

	#Install the python daemon
	python_foreach_impl python_doscript "${FILESDIR}/iwd-firewalld-zone-daemon"

	#Install the systemd unit
	systemd_dounit "${FILESDIR}/iwd-firewalld-zone-daemon@.service"
}

pkg_postinst() {
	elog "To enable ${PN} for a interface enable it via"
	elog "'systemctl enable ${PN}-daemon@<INTERFACE_NAME>.service'."
	elog ""
	elog "To set a zone for a network add 'FirewalldZone=<ZONE>'"
	elog "in the corresponding config file in '/var/lib/iwd'."
}
