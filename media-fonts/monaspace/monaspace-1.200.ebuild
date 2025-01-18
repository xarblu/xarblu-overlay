# Copyright 2019-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="An innovative superfamily of fonts for code"
HOMEPAGE="https://monaspace.githubnext.com/"
SRC_URI="https://github.com/githubnext/monaspace/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+otf variable"

REQUIRED_USE="|| ( otf variable )"

src_configure() {
	# move requested fonts to staging area
	local dir
	for dir in $(usev otf) $(usev variable); do
		mkdir -p staging/"${dir}" || die
		mv fonts/"${dir}"/* staging/"${dir}" || die
	done
}

src_install() {
	# enter staging area for sane install path
	pushd staging || die
	FONT_SUFFIX="$(usev otf) $(usev variable)"
	FONT_S=( $(usev otf) $(usev variable) )
	DOCS=( ../README.md )
	font_src_install
	popd || die
}
