# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Unified compiler shadow link directory updater"
HOMEPAGE="https://github.com/projg2/shadowman"
SRC_URI="https://github.com/projg2/shadowman/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE=""

RDEPEND="app-admin/eselect"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/sccache-wrappers.patch" )

src_install() {
	local tools
	if has_version "dev-util/sccache"; then
		tools="${tools} sccache"
	fi

	# tool modules are split into their respective packages
	emake DESTDIR="${D}" prefix="${EPREFIX}"/usr install \
		INSTALL_MODULES_TOOL="${tools}"
	keepdir /usr/share/shadowman/tools
}
