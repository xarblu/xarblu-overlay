# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10,11} )

inherit python-r1 python-utils-r1 systemd

DESCRIPTION="Custom Discord Rich Presence for Linux "
HOMEPAGE="https://github.com/xarblu/linux-discord-rpc"
SRC_URI="https://github.com/xarblu/linux-discord-rpc/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	$(python_gen_cond_dep 'dev-python/pypresence[${PYTHON_USEDEP}]')
"
RDEPEND="${DEPEND}"

src_install() {
	python_foreach_impl python_newscript ${PN}.py rpc-cli
	python_foreach_impl python_newscript ${PN}.py rpc-daemon
	systemd_douserunit ${PN}.service
	default
}
