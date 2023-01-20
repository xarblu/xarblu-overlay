# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

MY_PN="${PN^}"

DESCRIPTION="A digital logic designer and circuit simulator"
HOMEPAGE="https://github.com/hneemann/Digital"
SRC_URI="https://github.com/hneemann/${MY_PN}/releases/download/v${PV}/${MY_PN}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	virtual/jre
"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${MY_PN}"

src_install() {
	# Some setup variables
	INSTALLDIR="/opt/${PN}"
	JAR="${MY_PN}.jar"

	# Setup and install wrapper script
	cp "${FILESDIR}/wrapper.sh" "${S}"
	sed -i -e "s|%%INSTALLDIR%%|${INSTALLDIR}|" "${S}/wrapper.sh" || die "Failed setting up wrapper"
	sed -i -e "s|%%JAR%%|${JAR}|" 				"${S}/wrapper.sh" || die "Failed setting up wrapper"
	newbin "${S}/wrapper.sh" digital

	# Install main files
	insinto "${INSTALLDIR}"
	doins -r ${S}/{docu,examples,lib,${JAR},ReleaseNotes.txt,Version.txt,icon.svg}

	# Setup and install desktop files
	sed -i -e "s|<EXEC_LOCATION>|${PN}|" "${S}/linux/desktop.template" || die "Failed setting up .desktop"
	sed -i -e "s|<ICON_LOCATION>|${PN}|" "${S}/linux/desktop.template" || die "Failed setting up .desktop"
	newmenu "${S}/linux/desktop.template" "${PN}.desktop"
	newicon -s scalable "${S}/icon.svg" "${PN}.svg"
	insinto "/usr/share/mime/packages"
	doins "${S}/linux/digital-simulator.xml"
}
