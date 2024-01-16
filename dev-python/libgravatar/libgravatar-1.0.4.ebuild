# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..12} )

inherit distutils-r1 pypi

DESCRIPTION="A library that provides a Python 3 interface for the Gravatar API"
HOMEPAGE="https://pypi.org/project/libgravatar/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

#TODO: pytest
