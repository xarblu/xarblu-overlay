# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{9..11} )
inherit distutils-r1

DESCRIPTION="Cross-platform tool for adding locations to the user PATH"
HOMEPAGE="https://github.com/ofek/userpath"
SRC_URI="https://github.com/ofek/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/distro[${PYTHON_USEDEP}]
"
BDEPEND="
	test? ( $(python_gen_cond_dep 'dev-python/pytest[${PYTHON_USEDEP}]') )
"

distutils_enable_tests pytest
