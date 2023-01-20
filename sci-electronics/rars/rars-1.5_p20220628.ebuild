# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

#Handle version suffixes
if [[ ${PV} == *_p* ]]; then
	MY_PV="continuous"
	JAR="rars_27a7c1f.jar"
else
	MY_PV="v${PV}"
	JAR="rars${PV/./_}.jar"
fi

DESCRIPTION="RISC-V Assembler and Runtime Simulator "
HOMEPAGE="https://github.com/TheThirdOne/rars"
SRC_URI="https://github.com/TheThirdOne/${PN}/releases/download/${MY_PV}/${JAR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	virtual/jre
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_unpack() {
	mkdir ${S}
	cp "${DISTDIR}/${JAR}" ${S}
}

src_install() {
	# Some setup variables
	INSTALLDIR="/opt/${PN}"

	# Setup and install wrapper script
	cp "${FILESDIR}/wrapper.sh" "${S}"
	sed -i -e "s|%%INSTALLDIR%%|${INSTALLDIR}|" "${S}/wrapper.sh" || die "Failed setting up wrapper"
	sed -i -e "s|%%JAR%%|${JAR}|" 				"${S}/wrapper.sh" || die "Failed setting up wrapper"
	newbin "${S}/wrapper.sh" ${PN}

	# Install main files
	insinto "${INSTALLDIR}"
	doins "${S}/${JAR}"

	## Setup and install desktop files
	domenu "${FILESDIR}/rars.desktop"
	doicon -s 128 "${FILESDIR/rars.png}"
}
