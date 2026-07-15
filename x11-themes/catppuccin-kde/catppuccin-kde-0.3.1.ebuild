# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

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
FLAVOURS=( mocha macchiato frappe latte )
ACCENTS=( rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender )
STYLES=( modern classic )

setup_iuse() {
	IUSE="${FLAVOURS[*]/#/catppuccin_flavours_} ${ACCENTS[*]/#/catppuccin_accents_} ${STYLES[*]/#/catppuccin_styles_}"

	# defaults
	local i
	for i in catppuccin_flavours_mocha catppuccin_accents_lavender catppuccin_styles_classic; do
		IUSE="${IUSE/${i}/+${i}}"
	done
}
setup_iuse

# require at least one of each
# only allow 1 style because their directory names clash
REQUIRED_USE="
	|| ( ${FLAVOURS[*]/#/catppuccin_flavours_} )
	|| ( ${ACCENTS[*]/#/catppuccin_accents_} )
	^^ ( ${STYLES[*]/#/catppuccin_styles_} )
"

S="${WORKDIR}/${MY_P}"

PATCHES=( "${FILESDIR}/0.3.1-distro-package.patch" )

src_compile() {
	mkdir -p "${WORKDIR}"/out/{aurorae,global,color}

	local flavour style accent

	# aurorae theme depends on flavour and style
	for flavour in "${!FLAVOURS[@]}"; do
		use "catppuccin_flavours_${FLAVOURS[${flavour}]}" || continue
		for style in "${!STYLES[@]}"; do
			use "catppuccin_styles_${STYLES[${style}]}" || continue

			einfo "Making '${STYLES[${style}]}' windowdecorations for flavour '${FLAVOURS[${flavour}]}'"

			./install.sh \
				--quiet \
				"$(( flavour + 1 ))" \
				"1" \
				"$(( style + 1 ))" \
				"aurorae" \
				|| die "Making windowdecorations failed"

			# grab what we want then clean
			local name="Catppuccin${FLAVOURS[${flavour}]^}-${STYLES[${style}]^}"
			mv -nt "${WORKDIR}/out/aurorae/" "dist/${name}" || die "mv failed"
			rm -r dist || die "rm failed"
		done
	done

	# global theme depends on flavour, accent and style
	for flavour in "${!FLAVOURS[@]}"; do
		use "catppuccin_flavours_${FLAVOURS[${flavour}]}" || continue
		for accent in "${!ACCENTS[@]}"; do
			use "catppuccin_accents_${ACCENTS[${accent}]}" || continue
			for style in "${!STYLES[@]}"; do
				use "catppuccin_styles_${STYLES[${style}]}" || continue

				einfo "Making '${STYLES[${style}]}' global theme for flavour '${FLAVOURS[${flavour}]}' with haccent '${ACCENTS[${accent}]}'"

				./install.sh \
					--quiet \
					"$(( flavour + 1 ))" \
					"$(( accent + 1 ))" \
					"$(( style + 1 ))" \
					"global" \
					|| die "Making global themes failed"

				# grab what we want then clean
				local name="Catppuccin-${FLAVOURS[${flavour}]^}-${ACCENTS[${accent}]^}"
				mv -nt "${WORKDIR}/out/global/" "dist/${name}" || die "mv failed"

				# merge splash into global
				pushd "dist/${name}-splash" >/dev/null || die "pushd failed"
				local file
				while IFS='' read -rd '' file; do
					mkdir -p "${WORKDIR}/out/global/${name}/${file%/*}" || die "merge splash failed"
					mv -nt "${WORKDIR}/out/global/${name}/${file%/*}" "${file}" || die "merge splash failed"
				done < <(find . -type f -print0)
				popd >/dev/null || die "popd failed"

				rm -r dist || die "rm failed"
			done
		done
	done

	# colors depend on flavour and accent
	for flavour in "${!FLAVOURS[@]}"; do
		use "catppuccin_flavours_${FLAVOURS[${flavour}]}" || continue
		for accent in "${!ACCENTS[@]}"; do
			use "catppuccin_accents_${ACCENTS[${accent}]}" || continue

			einfo "Making colorscheme for flavour '${FLAVOURS[${flavour}]}' with accent '${ACCENTS[${accent}]}'"

			./install.sh \
				--quiet \
				"$(( flavour + 1 ))" \
				"$(( accent + 1 ))" \
				"1" \
				"color" \
				|| die "Making colorscheme failed"

			# grab what we want then clean
			local name="Catppuccin${FLAVOURS[${flavour}]^}${ACCENTS[${accent}]^}"
			mv -nt "${WORKDIR}/out/color/" "dist/${name}.colors" || die "mv failed"
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
