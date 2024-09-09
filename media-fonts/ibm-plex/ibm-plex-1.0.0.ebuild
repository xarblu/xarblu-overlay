# Copyright 2019-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="The package of IBM's typeface"
HOMEPAGE="https://github.com/IBM/plex"

# font variants
# <use>:<variant>
# -:<variant> -> unconditional
VARIANT_SPECS=(
	-:math
	-:mono
	-:sans-arabic
	-:sans-condensed
	-:sans-devanagari
	-:sans-hebrew
	cjk:sans-jp
	cjk:sans-kr
	cjk:sans-tc
	-:sans-thai-looped
	-:sans-thai
	-:sans
	-:serif
)

setup_variants () {
	local base="https://github.com/IBM/plex/releases/download/@ibm"
	local spec use variant
	for spec in "${VARIANT_SPECS[@]}"; do
		use="${spec%:*}"
		variant="${spec#*:}"
		[[ "${use}" != "-" ]] && SRC_URI+=" ${use}? ( "
		SRC_URI+=" ${base}/plex-${variant}@${PV}/ibm-plex-${variant}.zip -> ${PN}-${variant}-${PV}.zip "
		[[ "${use}" != "-" ]] && SRC_URI+=" ) "
		[[ "${use}" != "-" ]] && IUSE+=" ${use} "
	done
}
setup_variants

S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE+="otf +ttf"

REQUIRED_USE="^^ ( otf ttf )"

BDEPEND="app-arch/unzip"

src_install() {
	local otf ttf dir

	use otf && otf="otf"
	use ttf && otf="ttf"

	FONT_SUFFIX="${otf} ${ttf}"

	FONT_S=()
	for dir in ./*/fonts/complete/; do
		for type in ${otf} ${ttf}; do
			if [[ -d "${dir}/${type}/hinted" ]] && [[ -d "${dir}/${type}/unhinted" ]]; then
				FONT_S+=( "${dir}/${type}/hinted" "${dir}/${type}/unhinted" )
			elif [[ -d "${dir}/${type}/hinted" ]]; then
				FONT_S+=( "${dir}/${type}/hinted" )
			elif [[ -d "${dir}/${type}/unhinted" ]]; then
				FONT_S+=( "${dir}/${type}/unhinted" )
			else
				FONT_S+=( "${dir}/${type}" )
			fi
		done
	done

	font_src_install
}
