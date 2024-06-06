# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

DESCRIPTION="Python API to MPV using JSON IPC"
HOMEPAGE="https://github.com/iwalton3/python-mpv-jsonipc"
SRC_URI="https://github.com/iwalton3/python-mpv-jsonipc/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPENDS="${PYTHON_DEPS}"
RDEPENDS="${DEPENDS}"
BDEPENDS="${PYTHON_DEPS}"
