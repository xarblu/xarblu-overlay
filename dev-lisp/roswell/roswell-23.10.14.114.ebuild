# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="A lisp installer and launcher for major environment"
HOMEPAGE="https://github.com/roswell/roswell"
SRC_URI="https://github.com/roswell/roswell/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="MIT"

KEYWORDS="~amd64 ~x86"

# File collision with librouteros (#691754)
RDEPEND="
	!net-libs/librouteros
	net-misc/curl
"
DEPEND="${RDEPEND}"

PATCHES=(
	# llvm-core/llvm provides windres but bfd/lld
	# don't understand the resulting object
	"${FILESDIR}/no-windres.patch"
)

src_prepare() {
	default
	eautoreconf
}
