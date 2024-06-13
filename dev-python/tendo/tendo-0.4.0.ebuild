# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( python3_{10..13} )
inherit distutils-r1

DESCRIPTION="A Python library that extends some core functionality"
HOMEPAGE="https://pypi.org/project/tendo/"
SRC_URI="https://github.com/pycontribs/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="
	$(python_gen_cond_dep '
		dev-python/setuptools-scm[${PYTHON_USEDEP}]
	')
"

src_compile() {
	# archive doesn't have git history
	export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"
	distutils-r1_src_compile
}
