# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="cursors"

DESCRIPTION="Soothing pastel mouse cursors"
HOMEPAGE="https://github.com/catppuccin/cursors"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# available flavours and accent colours
FLAVOURS="mocha macchiato frappe latte"
ACCENTS="rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender dark light"

# mocha is default
IUSE="${FLAVOURS/mocha/+mocha}"

REQUIRED_USE="|| ( ${FLAVOURS} )"

# we'll download the release
# the inkspace dependency isn't worth it
src_uris() {
	local base="https://github.com/catppuccin/${MY_PN}/releases/download/v${PV}"
	for flavour in ${FLAVOURS}; do
		SRC_URI+=" ${flavour}? ( "
		for accent in ${ACCENTS}; do
			SRC_URI+="
				${base}/Catppuccin-${flavour^}-${accent^}-Cursors.zip
					-> ${PN}-${flavour}-${accent}-${PV}.zip
			"
		done
		SRC_URI+=" )"
	done
}
src_uris

BDEPEND="app-arch/unzip"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/icons/
	# we only downloaded and unpacked what we wanted
	doins -r *
}
