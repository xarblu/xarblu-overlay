# Copyright 2019-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="An innovative superfamily of fonts for code"
HOMEPAGE="https://monaspace.githubnext.com/"
SRC_URI="https://github.com/githubnext/monaspace/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DOCS=( README.md )

src_install() {
FONT_SUFFIX="otf"
FONT_S=( fonts/otf )
font_src_install
}
