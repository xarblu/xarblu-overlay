# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} pypy3_11 )
inherit python-r1 pypi

DESCRIPTION="Python API Client for Jellyfin"
HOMEPAGE="
	https://github.com/jellyfin/jellyfin-apiclient-python
	https://pypi.org/project/jellyfin-apiclient-python/
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	dev-python/websocket-client[${PYTHON_USEDEP}]
	dev-python/certifi[${PYTHON_USEDEP}]
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND="${PYTHON_DEPS}"

# doesn't use proper setuptools...
src_install() {
	python_foreach_impl python_domodule jellyfin_apiclient_python
}
