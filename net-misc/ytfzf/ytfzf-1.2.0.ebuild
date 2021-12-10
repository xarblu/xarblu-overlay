# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit optfeature

DESCRIPTION="A posix script that helps you find Youtube videos and opens using mpv/youtube-dl"
HOMEPAGE="https://github.com/pystardust/ytfzf"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/pystardust/ytfzf.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/pystardust/ytfzf/archive/v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
app-shells/fzf
app-misc/jq
media-video/mpv
|| ( net-misc/youtube-dl net-misc/yt-dlp )
"

DOCS=( README.md docs/conf.sh )

src_compile() {
	# Upstream provides a makefile, but there is nothing to compile
	# Set to 'true' to prevent sandbox errors when src_compile triggers make install
	true
}

src_install() {
	# To prevent make install from failing
	dodir "usr/bin"

	emake DESTDIR="${D}" PREFIX=/usr/bin install
	einstalldocs
}
