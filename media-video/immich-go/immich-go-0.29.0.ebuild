# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

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
KEYWORDS="~amd64"

src_compile() {
	# https://github.com/simulot/immich-go/blob/v0.29.0/.goreleaser.yaml
	export CGO_ENABLED=0
	local -a ldflags=(
		-X "github.com/simulot/immich-go/app.Version=${PV}"
	)
	ego build -trimpath -ldflags="${ldflags[*]}" -o="${PN}"
}

src_install() {
	dobin "${PN}"
}
