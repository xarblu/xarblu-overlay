# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Preconfigured set of MPV shaders and configs for MPV Shim media clients."
HOMEPAGE="https://github.com/iwalton3/default-shader-pack"

SRC_URI="
	https://github.com/iwalton3/default-shader-pack/archive/v${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="MIT LGPL-3 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/default-shader-pack-${PV}"

src_install() {
	insinto "usr/share/${PN}"
	doins -r shaders pack.json
}
