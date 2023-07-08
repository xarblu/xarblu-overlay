# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10,11} )

inherit systemd distutils-r1

DESCRIPTION="Custom Discord Rich Presence for Linux "
HOMEPAGE="https://github.com/xarblu/linux-discord-rpc"
SRC_URI="https://github.com/xarblu/linux-discord-rpc/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	$(python_gen_cond_dep '
		dev-python/pypresence[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
	')
"
RDEPEND="${DEPEND}"

src_install() {
	distutils-r1_src_install
	systemd_douserunit extra/${PN}.service
	default
}
