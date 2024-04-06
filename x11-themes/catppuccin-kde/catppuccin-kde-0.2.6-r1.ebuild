# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="kde"

if [[ "${PV}" == *_pre* ]]; then
	MY_PV=""
	SRC_A="${MY_PV}.tar.gz"
else
	MY_PV="${PV}"
	SRC_A="v${MY_PV}.tar.gz"
fi
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Soothing pastel theme for KDE"
HOMEPAGE="https://github.com/catppuccin/kde"
SRC_URI="https://github.com/catppuccin/${MY_PN}/archive/${SRC_A} -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# order as in ./install.sh !IMPORTANT!
FLAVOURS="mocha macchiato frappe latte"
ACCENTS="rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender"
STYLES="modern classic"

setup_iuse() {
	local i
	for i in ${FLAVOURS}; do
		IUSE_FLAVOURS="${IUSE_FLAVOURS# } catppuccin_flavours_${i}"
	done
	for i in ${ACCENTS}; do
		IUSE_ACCENTS="${IUSE_ACCENTS# } catppuccin_accents_${i}"
	done
	for i in ${STYLES}; do
		IUSE_STYLES="${IUSE_STYLES# } catppuccin_styles_${i}"
	done

	IUSE="${IUSE_FLAVOURS} ${IUSE_ACCENTS} ${IUSE_STYLES}"

	# defaults
	for i in catppuccin_flavours_mocha catppuccin_accents_lavender catppuccin_styles_classic; do
		IUSE="${IUSE/${i}/+${i}}"
	done
}
setup_iuse

# require at least one of each
# only allow 1 style because their directory names clash
REQUIRED_USE="
	|| ( ${IUSE_FLAVOURS} )
	|| ( ${IUSE_ACCENTS} )
	^^ ( ${IUSE_STYLES} )
"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	einfo "Removing unneded steps from install.sh"
	# we don't need these deps
	sed -i -e '/check_command_exists ".*"/d' install.sh || die "sed failed"
	# remove unnecessary sleeps, they just slow things down
	sed -i -e '/.*sleep.*/d' install.sh || die "sed failed"
	# don't use kpackagetool
	sed -i -e '/.*kpackagetool.*/d' install.sh || die "sed failed"
	default
}

src_compile() {
	# we need these as arrays
	local flavours=( ${FLAVOURS} )
	local accents=( ${ACCENTS} )
	local styles=( ${STYLES} )

	mkdir -p "${WORKDIR}"/out/{aurorae,global,color}

	# aurorae theme depends on flavour and style
	for flavour in "${!flavours[@]}"; do
		use "catppuccin_flavours_${flavours[${flavour}]}" || continue
		for style in "${!styles[@]}"; do
			use "catppuccin_styles_${styles[${style}]}" || continue
			einfo "Making '${styles[${style}]}' windowdecorations for flavour '${flavours[${flavour}]}'"
			./install.sh "$(( flavour + 1 ))" "1" "$(( style + 1 ))" "aurorae" >/dev/null \
				|| die "Making windowdecorations failed"
			# grab what we want then clean
			local name="Catppuccin${flavours[${flavour}]^}-${styles[${style}]^}"
			mv "dist/${name}" "${WORKDIR}/out/aurorae/" || die "mv failed"
			rm -r dist || die "rm failed"
		done
	done

	# global theme depends on flavour, accent and style
	for flavour in "${!flavours[@]}"; do
		use "catppuccin_flavours_${flavours[${flavour}]}" || continue
		for accent in "${!accents[@]}"; do
			use "catppuccin_accents_${accents[${accent}]}" || continue
			for style in "${!styles[@]}"; do
				use "catppuccin_styles_${styles[${style}]}" || continue
				einfo "Making '${styles[${style}]}' global theme for flavour '${flavours[${flavour}]}' with haccent '${accents[${accent}]}'"
				./install.sh "$(( flavour + 1 ))" "$(( accent + 1 ))" "$(( style + 1 ))" "global" >/dev/null \
					|| die "Making global themes failed"
				# grab what we want then clean
				local name="Catppuccin-${flavours[${flavour}]^}-${accents[${accent}]^}"
				mv "dist/${name}" "${WORKDIR}/out/global/" || die "mv failed"
				# merge splash into global
				pushd "dist/${name}-splash" >/dev/null || die "pushd failed"
				for file in $(find . -type f); do
					mkdir -p "${WORKDIR}/out/global/${name}/$(dirname "${file}")" || die "merge splash failed"
					mv "${file}" "${WORKDIR}/out/global/${name}/${file}" || die "merge splash failed"
				done
				popd >/dev/null || die "popd failed"
				rm -r dist || die "rm failed"
			done
		done
	done

	# colors depend on flavour and accent
	for flavour in "${!flavours[@]}"; do
		use "catppuccin_flavours_${flavours[${flavour}]}" || continue
		for accent in "${!accents[@]}"; do
			use "catppuccin_accents_${accents[${accent}]}" || continue
			einfo "Making colorscheme for flavour '${flavours[${flavour}]}' with accent '${accents[${accent}]}'"
			./install.sh "$(( flavour + 1 ))" "$(( accent + 1 ))" "1" "color" >/dev/null \
				|| die "Making colorscheme failed"
			# grab what we want then clean
			local name="Catppuccin${flavours[${flavour}]^}${accents[${accent}]^}"
			mv "dist/${name}.colors" "${WORKDIR}/out/color/" || die "mv failed"
			rm -r dist || die "rm failed"
		done
	done
}

src_install() {
	# aurorae theme
	insinto /usr/share/aurorae/themes/
	doins -r "${WORKDIR}"/out/aurorae/*
	# global theme
	insinto /usr/share/plasma/look-and-feel/
	doins -r "${WORKDIR}"/out/global/*
	# color scheme
	insinto /usr/share/color-schemes/
	doins -r "${WORKDIR}"/out/color/*
}
