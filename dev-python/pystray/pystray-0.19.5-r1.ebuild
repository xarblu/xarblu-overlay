# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} pypy3_11 )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Python library for creating system tray icons"
HOMEPAGE="
	https://github.com/moses-palmer/pystray
	https://pypi.org/project/pystray/
"
SRC_URI="https://github.com/moses-palmer/pystray/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/python-xlib[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	dev-libs/libayatana-appindicator
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-python/sphinx[${PYTHON_USEDEP}]
"
