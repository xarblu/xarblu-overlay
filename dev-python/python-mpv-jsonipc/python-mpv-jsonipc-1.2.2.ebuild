# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( python3_{12..14}  )
inherit distutils-r1 pypi

DESCRIPTION="Python API to MPV using JSON IPC"
HOMEPAGE="
	https://github.com/iwalton3/python-mpv-jsonipc
	https://pypi.org/project/python-mpv-jsonipc/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPENDS="${PYTHON_DEPS}"
RDEPENDS="${DEPENDS}"
BDEPENDS="${PYTHON_DEPS}"
