# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} pypy3_11 )
inherit distutils-r1 pypi

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

# use some legacy version of dev-python/tox
# and tries to pip install during test
RESTRICT="test"

PATCHES=( "${FILESDIR}/1.12.0-fix-pyproject_toml.patch" )
