# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Tool to streamline uploading large photo collections to your Immich server"
HOMEPAGE="https://github.com/simulot/immich-go"
SRC_URI="
	https://github.com/simulot/immich-go/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/xarblu/xarblu-overlay/releases/download/distfiles/${P}-deps.tar.xz
"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_compile() {
	ego build
}

src_install() {
	dobin immich-go
}
