# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Symlinks and syncs browser profile dirs to RAM"
HOMEPAGE="https://wiki.archlinux.org/title/Profile-sync-daemon"

SRC_URI="https://github.com/graysky2/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	app-shells/bash
	net-misc/rsync[xattr]
	sys-apps/systemd"

src_install() {
	emake DESTDIR="${D}" COMPRESS_MAN=0 install
}
