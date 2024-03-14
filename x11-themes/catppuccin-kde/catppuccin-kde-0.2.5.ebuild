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

setup_iuse() {
	local i
	for i in ${FLAVOURS}; do
		IUSE_FLAVOURS="${IUSE_FLAVOURS# } catppuccin_flavours_${i}"
	done
	for i in ${ACCENTS}; do
		IUSE_ACCENTS="${IUSE_ACCENTS# } catppuccin_accents_${i}"
	done

	IUSE="+splashscreen ${IUSE_FLAVOURS} ${IUSE_ACCENTS}"

	# defaults
	for i in catppuccin_flavours_mocha catppuccin_accents_lavender; do
		IUSE="${IUSE/${i}/+${i}}"
	done
}
setup_iuse

REQUIRED_USE="
	|| ( ${IUSE_FLAVOURS} )
	|| ( ${IUSE_ACCENTS} )
"

S="${WORKDIR}/${MY_PN}-${PV}"
COLORDEST="${WORKDIR}/colors"
SPLASHDEST="${WORKDIR}/splash"

src_prepare() {
	# we don't need these deps
	sed -i -e '/check_command_exists ".*"/d' install.sh || die "sed failed"
	# remove unnecessary sleeps, they just slow things down
	sed -i -e '/.*sleep.*/d' install.sh || die "sed failed"
	# fix issue with only splashscreen
	sed -i -e '426s/GLOBALTHEMENAME=".*"/GLOBALTHEMENAME="$SPLASHSCREENNAME"/' \
		install.sh || die "sed failed"
	default
}

src_compile() {
	# TODO: global themes
	# however they are just a patched "lightly" theme
	# not sure if they'll work looking towards plasma 6

	# we need these as arrays
	local flavours=( ${FLAVOURS} )
	local accents=( ${ACCENTS} )

	# create our dest dirs
	mkdir -p "${COLORDEST}" "${SPLASHDEST}"

	for flavour in "${!flavours[@]}"; do
		use catppuccin_flavours_${flavours[${flavour}]} || continue
		for accent in "${!accents[@]}"; do
			use catppuccin_accents_${accents[${accent}]} || continue
			einfo "Making colorscheme for flavour '${flavours[${flavour}]}' with accent '${accents[${accent}]}'"
			# NOTES:
			# 1) script wants indices starting at 1
			# 2) stdout has control chars -> messes with terminal
			./install.sh "$(( ${flavour} + 1 ))" "$(( ${accent} + 1 ))" "1" "color" &>/dev/null \
				|| die "Making colorscheme failed"
			# grab what we want then clean
			mv dist/Catppuccin*.colors "${COLORDEST}" || die "mv failed"
			rm -r dist || die "rm failed"

			if use splashscreen; then
				einfo "Making splashscreen for flavour '${flavours[${flavour}]}' with accent '${accents[${accent}]}'"
				# NOTES:
				# 1) script wants indices starting at 1
				# 2) stdout has control chars -> messes with terminal
				./install.sh "$(( ${flavour} + 1 ))" "$(( ${accent} + 1 ))" "1" "splash" &>/dev/null \
					|| die "Making splashscreen failed"
				# grab what we want then clean
				mv dist/Catppuccin*-splash "${SPLASHDEST}" || die "mv failed"
				rm -r dist || die "rm failed"
			fi
		done
	done
}

src_install() {
	insinto /usr/share/color-schemes/
	doins "${COLORDEST}"/*

	if use splashscreen; then
		insinto /usr/share/plasma/look-and-feel
		doins -r "${SPLASHDEST}"/*
	fi
}
