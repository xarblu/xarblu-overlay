# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )
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
"
RDEPEND="${DEPEND}"
BDEPEND=""
