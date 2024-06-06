# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

DESCRIPTION="Python API Client for Jellyfin"
HOMEPAGE="https://github.com/jellyfin/jellyfin-apiclient-python"
SRC_URI="https://github.com/jellyfin/jellyfin-apiclient-python/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	dev-python/websocket-client[${PYTHON_USEDEP}]
	dev-python/certifi[${PYTHON_USEDEP}]
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND="${PYTHON_DEPS}"
