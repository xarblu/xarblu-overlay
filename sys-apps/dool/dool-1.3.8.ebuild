# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{13..15} )

inherit distutils-r1

DESCRIPTION="Versatile replacement for vmstat, iostat and ifstat (clone of dstat)"
HOMEPAGE="https://github.com/scottchiefbaker/dool"

SRC_URI="
	https://github.com/scottchiefbaker/dool/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
"
KEYWORDS="~amd64 ~arm64 ~mips ~ppc ~ppc64 ~sparc ~x86 "

LICENSE="GPL-3"
SLOT="0"

PATCHES=(
	"${FILESDIR}/1.3.8-fix_all-plugins_crashing_on_PARAM_REQUIRED_plugins.patch"
)

src_prepare() {
	default

	# convert simple script to a distutils compatible package
	# https://github.com/scottchiefbaker/dool/pull/80
	mv dool dool.py || die

	mkdir dool || die
	mv plugins dool || die
	mv dool.py dool || die

	cat <<-EOF > dool/__init__.py || die
	"""Versatile replacement for vmstat, iostat and ifstat (clone of dstat)"""
	__version__ = "${PV}"
	EOF

	sed -i 's/dool:__main__.__main/dool.dool:__main/' pyproject.toml || die
}

src_install() {
	distutils-r1_src_install

	doman "docs/${PN}.1"

	einstalldocs

	docinto html
	dodoc docs/*.html
}

# test function matching Makefile:test
python_test() {
	local dool="${BUILD_DIR}/install/usr/bin/dool"

	# version "test"
	"${dool}" --version || die

	# all builtins
	"${dool}" -taf 1 5 || die

	# all plugins (seems very flaky so we'll skip this for now)
	#"${dool}" -t --all-plugins 1 5 || die
}

