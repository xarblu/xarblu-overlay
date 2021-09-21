# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="lolcat"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="High-performance implementation of lolcat"
HOMEPAGE="https://github.com/jaseg/lolcat"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/jaseg/${MY_PN}.git"
else
	SRC_URI="https://github.com/jaseg/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${MY_P}"
fi

RESTRICT="mirror"
LICENSE="WTFPL-2"
SLOT="0"

src_install() {
	einstalldocs

	exeinto "/usr/bin"
	newexe "${MY_PN}" "${PN}"
	doexe "censor"
}
