# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{9..11} )
inherit distutils-r1

DESCRIPTION="Install and Run Python Applications in Isolated Environments"
HOMEPAGE="https://pypa.github.io/pipx/"
SRC_URI="https://github.com/pypa/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="test"

RDEPEND="
	dev-python/argcomplete[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/userpath[${PYTHON_USEDEP}]
	dev-python/pip[${PYTHON_USEDEP}]
"
