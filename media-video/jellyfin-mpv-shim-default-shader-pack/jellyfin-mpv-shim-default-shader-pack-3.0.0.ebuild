# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

DESCRIPTION="Preconfigured set of MPV shaders and configs for MPV Shim media clients"
HOMEPAGE="https://github.com/iwalton3/default-shader-pack"

SRC_URI="
	https://github.com/iwalton3/default-shader-pack/archive/v${PV}.tar.gz -> ${P}.tar.gz
"
S="${WORKDIR}/default-shader-pack-${PV}"

LICENSE="MIT LGPL-3 Unlicense"
SLOT="0"
KEYWORDS="~amd64"

src_install() {
	insinto "usr/share/${PN}"
	doins -r \
		shaders \
		pack-hq.json \
		pack-next.json \
		pack.json
}
