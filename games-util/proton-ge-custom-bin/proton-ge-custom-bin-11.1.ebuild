# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

MY_PN="GE-Proton"
MY_PV="${PV//./-}"
MY_P="${MY_PN}${MY_PV}"

DESCRIPTION="Custom distribution of Valves Proton with various patches"
HOMEPAGE="https://github.com/GloriousEggroll/proton-ge-custom"

SRC_URI="
	amd64? ( https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${MY_P}/${MY_P}.tar.gz )
	arm64? ( https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${MY_P}/${MY_P}-aarch64.tar.gz )
"
S="${WORKDIR}/${MY_P}"

# from dist.LICENSE
LICENSE="LGPL-2.1 ZLIB libpng LGPL-2 OFL-1.1 MIT MPL-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

# this ebuild expects
# the steam runtime
RDEPEND="
	games-util/steam-launcher[steam-runtime(+)]
"

# all prebuilt
QA_PREBUILT="*"

# we will install Proton with this name
# to avoid conflicting with other installs
INST_P="${MY_PN}-Portage"

src_unpack() {
	default

	if use arm64; then
		mv "${WORKDIR}/${MY_P}"{-aarch64,} || die
	fi
}

src_prepare() {
	sed -i -e "s/${MY_P}/${INST_P}/g" compatibilitytool.vdf || die

	default
}

src_install() {
	local compatd="/usr/share/steam/compatibilitytools.d"

	dodir "${compatd}"

	# mv to preserve mode
	mv "${WORKDIR}/${MY_P}" "${ED}/${compatd}/${INST_P}" || die
	fowners -R root:root "${compatd}/${INST_P}"
}
