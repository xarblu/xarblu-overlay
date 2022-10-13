# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="A rudimentary CLI hex editor programmed in C, probably not memory safe"
HOMEPAGE="https://github.com/1UPNuke/CLIHexEditor"

#Handle version suffixes
case ${PV} in
   *_alpha)
   	MY_PV="alpha-${PV%%_alpha}"
   	;;
   *_beta)
   	MY_PV="beta-${PV%%_beta}"
   	;;
   *)
   	MY_PV="${PV}"
   	;;
esac

if [[ ${MY_PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/1UPNuke/CLIHexEditor.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/1UPNuke/CLIHexEditor/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${PN}-${MY_PV}"
fi

LICENSE="MIT"
SLOT="0"

src_compile() {
	$(tc-getCC) ${CFLAGS} -Wall hexeditor.c -o hexeditor
}

src_install() {
	exeinto /usr/bin
	doexe hexeditor
}
