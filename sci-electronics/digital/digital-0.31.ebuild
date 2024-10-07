# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop wrapper

MY_PN="${PN^}"

DESCRIPTION="A digital logic designer and circuit simulator"
HOMEPAGE="https://github.com/hneemann/Digital"
SRC_URI="https://github.com/hneemann/${MY_PN}/releases/download/v${PV}/${MY_PN}.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="virtual/jre"
BDEPEND="app-arch/unzip"

S="${WORKDIR}/${MY_PN}"

src_install() {
	# Some setup variables
	INSTALLDIR="/opt/${PN}"
	JAR="${MY_PN}.jar"

	# Wrapper for easy launching
	make_wrapper digital "java -Dawt.useSystemAAFontSettings=on -jar ${INSTALLDIR}/${JAR}"

	# Install main files
	insinto "${INSTALLDIR}"
	doins -r docu examples lib "${JAR}" ReleaseNotes.txt Version.txt icon.svg

	# Setup and install desktop files
	sed -i -e "s|<EXEC_LOCATION>|${PN}|" "${S}/linux/desktop.template" || die "Failed setting up .desktop"
	sed -i -e "s|<ICON_LOCATION>|${PN}|" "${S}/linux/desktop.template" || die "Failed setting up .desktop"
	newmenu "${S}/linux/desktop.template" "${PN}.desktop"
	newicon -s scalable "${S}/icon.svg" "${PN}.svg"
	insinto "/usr/share/mime/packages"
	doins "${S}/linux/digital-simulator.xml"
}
