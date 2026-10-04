# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15}  )
inherit distutils-r1

DESCRIPTION="Python API Client for Jellyfin"
HOMEPAGE="
	https://github.com/jellyfin/jellyfin-apiclient-python
	https://pypi.org/project/jellyfin-apiclient-python/
"
# some unittest files only exists in the git repo and not in pypi releases
SRC_URI="
	https://github.com/jellyfin/jellyfin-apiclient-python/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
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

src_prepare() {
	default

	# pyproject.toml doesn't specify build-backend
	sed -i -e '/^\[build-system\]/a build-backend = "setuptools.build_meta"' pyproject.toml || die
}

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
