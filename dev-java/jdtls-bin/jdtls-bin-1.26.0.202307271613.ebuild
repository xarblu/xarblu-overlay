# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit java-pkg-2

MY_PV="$(ver_cut 1-3)"
JDTLS_DATE="$(ver_cut 4)"

DESCRIPTION="Java language server"
HOMEPAGE="https://github.com/eclipse-jdtls/eclipse.jdt.ls"
SRC_URI="https://download.eclipse.org/jdtls/milestones/${MY_PV}/jdt-language-server-${MY_PV}-${JDTLS_DATE}.tar.gz -> ${P}.tar.gz"

LICENSE="EPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=virtual/jre-1.8
"

S="${WORKDIR}"

src_install() {
	JDTLS_DIR="/usr/share/java/jdtls"
	dodir "${JDTLS_DIR}"
	cp -r config_* features plugins bin "${ED}/${JDTLS_DIR}"
	dosym "../../${JDTLS_DIR}/bin/jdtls" "/usr/bin/jdtls"
}
