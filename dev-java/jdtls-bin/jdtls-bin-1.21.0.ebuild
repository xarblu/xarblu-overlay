# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit java-pkg-2

JDTLS_REV="202303161431"

DESCRIPTION="Java language server"
HOMEPAGE="https://github.com/eclipse/eclipse.jdt.ls"
SRC_URI="https://download.eclipse.org/jdtls/milestones/${PV}/jdt-language-server-${PV}-${JDTLS_REV}.tar.gz -> ${P}.tar.gz"

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
