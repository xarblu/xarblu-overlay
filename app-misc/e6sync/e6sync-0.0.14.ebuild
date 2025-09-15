# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

PYTHON_COMPAT=( python3_{13..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1

DESCRIPTION="Downloader for the funny number site"
HOMEPAGE="https://github.com/xarblu/e6sync"
SRC_URI="https://github.com/xarblu/e6sync/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
"
RDEPEND="
	media-libs/exiftool
	${DEPEND}
"
