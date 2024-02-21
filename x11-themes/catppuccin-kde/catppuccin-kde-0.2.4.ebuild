# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="kde"

DESCRIPTION="Soothing pastel theme for KDE"
HOMEPAGE="https://github.com/catppuccin/kde"
SRC_URI="https://github.com/catppuccin/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# order as in ./install.sh !IMPORTANT!
FLAVOURS="mocha macchiato frappe latte"
ACCENTS="rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender"

# mocha is default
IUSE="${FLAVOURS/mocha/+mocha}"

REQURED_USE="|| ( ${FLAVOURS} )"

S="${WORKDIR}/${MY_PN}-${PV}"

make_colourschemes() {
	local flavour="${1}"
	local flavours=( ${FLAVOURS} )
	local accents=( ${ACCENTS} )

	for accent in "${!accents[@]}"; do
		einfo "Making colourscheme for flavour '${flavours[${flavour}]}' with accent '${accents[${accent}]}'"
		# NOTES:
		# 1) script wants indices starting at 1
		# 2) stdout has control chars -> messes with terminal
		#    stderr spams mkdir errors on recurring runs
		./install.sh "$(( ${flavour} + 1 ))" "$(( ${accent} + 1 ))" "2" "color" &>/dev/null \
			|| die "Making colourscheme failed"
	done
}

src_compile() {
	# color schemes
	local flavours=( ${FLAVOURS} )
	for flavour in "${!flavours[@]}" ; do
		use ${flavours[${flavour}]} && make_colourschemes "${flavour}"
	done

	# TODO: global and splash themes
	# however they are just a patched "lightly" theme
	# not sure if they'll work looking towards plasma 6
}

src_install() {
	insinto /usr/share/color-schemes/
	doins dist/Catppuccin*.colors
}
