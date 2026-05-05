# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} pypy3_11 )
inherit distutils-r1 pypi

DESCRIPTION="Python library for creating system tray icons"
HOMEPAGE="
	https://github.com/moses-palmer/pystray
	https://pypi.org/project/pystray/
"
# somehow not hosted on https://files.pythonhosted.org so fetch from upstream
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

# tests are interactive
# (e.g. "Is tray icon visible?" prompts)
RESTRICT="test"
