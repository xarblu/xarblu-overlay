# Copyright 2019-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="The package of IBM's typeface"
HOMEPAGE="https://github.com/IBM/plex"

# font variants
# <use>:<variant>@<git tag without @ibm/ prefix>
# because apparently it's hard to enforce consistent tag schemes...
# -:<variant> -> unconditional
VARIANT_SPECS=(
	-:ibm-plex-math@plex-math@1.1.0
	-:ibm-plex-mono@plex-mono@1.1.0
	-:ibm-plex-sans-arabic@plex-sans-arabic@1.1.0
	-:ibm-plex-sans-condensed@plex-sans-condensed@1.1.0
	-:ibm-plex-sans-devanagari@plex-sans-devanagari@1.1.0
	-:ibm-plex-sans-hebrew@plex-sans-hebrew@1.1.0
	-:ibm-plex-sans-thai-looped@plex-sans-thai-looped@1.1.0
	-:ibm-plex-sans-thai@plex-sans-thai@1.1.0
	-:ibm-plex-sans@plex-sans@1.1.0
	-:ibm-plex-serif@plex-serif@1.1.0
	cjk:ibm-plex-sans-jp@plex-sans-jp@2.0.0
	cjk:ibm-plex-sans-kr@plex-sans-kr@1.1.0
	cjk:ibm-plex-sans-sc@plex-sans-sc@1.1.0
	cjk:ibm-plex-sans-tc@plex-sans-tc@1.1.1
	variable:plex-sans-variable@plex-sans-variable@0.2.0
)

setup_variants() {
	local base="https://github.com/IBM/plex/releases/download"
	local spec font_use font_p font_pn font_tag
	for spec in "${VARIANT_SPECS[@]}"; do
		font_use="${spec%:*}"
		font_p="${spec#*:}"
		font_pn="${font_p%%@*}"
		font_tag="${font_p#*@}"
		font_pv="${font_tag#*@}"

		# if no version is given default to PV minus patch
		[[ "${font_pn}" == "${font_tag}" ]] && die "No tag set for spec ${spec}"

		# setup SRC_URI (and IUSE where set)
		[[ "${font_use}" != "-" ]] && SRC_URI+=" ${font_use}? ( "
		SRC_URI+="
			${base}/%40ibm%2F${font_tag//@/%40}/${font_pn}.zip
				-> ${font_pn}-${font_pv}.zip
		"
		[[ "${font_use}" != "-" ]] && SRC_URI+=" ) "
		[[ "${font_use}" != "-" ]] && IUSE+=" ${font_use} "
	done
}
setup_variants

S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE+="otf +ttf variable"

REQUIRED_USE="
	^^ ( otf ttf )
	variable? ( ttf )
"

BDEPEND="app-arch/unzip"

src_prepare() {
	default

	# staging area for sane install path
	mkdir -p "staging" || die
	local src dest
	while IFS= read -r -d $'\0' src; do
		mv -v -n -t "staging" "${src}" || die
	done < <(find . "(" -type f -and "(" -name "*.otf" -or -name "*.ttf" ")" ")" -print0)
}

src_install() {
	# enter staging area to not have path in install location
	cd staging || die

	# select types and install
	FONT_SUFFIX="$(usev otf) $(usev ttf)"
	FONT_S=( . )
	font_src_install
}
