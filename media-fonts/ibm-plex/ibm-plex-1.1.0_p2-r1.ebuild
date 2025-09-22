# Copyright 2019-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit font

DESCRIPTION="The package of IBM's typeface"
HOMEPAGE="https://github.com/IBM/plex"

COMMIT='89cba80dad75561262e758f4b6ddd474c5119796'

# spec for each relevant font file in the repo within the packages/ dir
# we will download them individually because archives of the entire repo
# are over 1GB even when compressed
# format: <use>:<dir>:<family>:<types>:<hinted>:<tier>
# use: use flag guardig the font e.g. cjk
# dir: font root dir e.g. ibm-mono
# name: font name e.g. IBMPlexMono
# types: comma seperated available types otf,ttf
# hinted: comma separated types that are split in hinted/unhinted
# tier: "tier" of font
#       1 -> only Regular
#       8 -> 8 variants
#       16 -> 16 variants
# shellcheck disable=SC2054
FONT_SPECS=(
	-:plex-math:IBMPlexMath:otf,ttf::1
	-:plex-mono:IBMPlexMono:otf,ttf::16
	-:plex-sans-arabic:IBMPlexSansArabic:otf,ttf::8
	-:plex-sans-condensed:IBMPlexSansCondensed:otf,ttf::16
	-:plex-sans-devanagari:IBMPlexSansDevanagari:otf,ttf::8
	-:plex-sans-hebrew:IBMPlexSansHebrew:otf,ttf::8
	cjk:plex-sans-jp:IBMPlexSansJP:otf,ttf:otf,ttf:8
	cjk:plex-sans-kr:IBMPlexSansKR:otf,ttf:ttf:8
	cjk:plex-sans-sc:IBMPlexSansSC:otf,ttf:otf,ttf:8
	cjk:plex-sans-tc:IBMPlexSansTC:otf,ttf:otf,ttf:8
	-:plex-sans-thai-looped:IBMPlexSansThaiLooped:otf,ttf::8
	-:plex-sans-thai:IBMPlexSansThai:otf,ttf::8
	'variable:plex-sans-variable:IBM Plex Sans Var:ttf::variable'
	-:plex-sans:IBMPlexSans:otf,ttf::16
	-:plex-serif:IBMPlexSerif:otf,ttf::16
)

setup_fonts() {
	local base="https://github.com/IBM/plex/raw/${COMMIT}/packages"
	local font_use font_dir font_family font_types font_hinted font_tier
	local url
	while IFS=':' read -r font_use font_dir font_family font_types font_hinted font_tier; do
		url="${base}/${font_dir}/fonts/complete"

		IFS=',' read -r -a font_types <<<"${font_types}"

		local -a font_variants
		case "${font_tier}" in
			1) font_variants=( Regular ) ;;
			8) font_variants=(
					Bold ExtraLight Light Medium
					Regular SemiBold Text Thin
				) ;;
			16) font_variants=(
					Bold BoldItalic ExtraLight ExtraLightItalic
					Italic Light LightItalic Medium
					MediumItalic Regular SemiBold SemiBoldItalic
					Text Text Thin ThinItalic
				) ;;
			# variable font is special
			variable) font_variants=( Italic Roman ) ;;
			*) die "Unknown font_tier: ${font_tier}" ;;
		esac

		# guard by USE if specified
		if [[ "${font_use}" != '-' ]]; then
			SRC_URI+=" ${font_use}? ( "
		fi

		# generate final urls
		local font_type font_variant
		for font_type in "${font_types[@]}"; do
			for font_variant in "${font_variants[@]}"; do
				if [[ "${font_hinted}" == *"${font_type}"* ]]; then
					SRC_URI+=" ${font_type}? (
						${url}/${font_type}/hinted/${font_family// /%20}-${font_variant}.${font_type}
							-> ${font_family// /_}-${font_variant}-Hinted-${COMMIT::8}.${font_type}
					) "
					SRC_URI+=" ${font_type}? (
						${url}/${font_type}/unhinted/${font_family// /%20}-${font_variant}.${font_type}
							-> ${font_family// /_}-${font_variant}-Unhinted-${COMMIT::8}.${font_type}
					) "
				else
					SRC_URI+=" ${font_type}? (
						${url}/${font_type}/${font_family// /%20}-${font_variant}.${font_type}
							-> ${font_family// /_}-${font_variant}-${COMMIT::8}.${font_type}
					) "
				fi
			done
		done

		# guard by USE if specified
		if [[ "${font_use}" != '-' ]]; then
			SRC_URI+=" ) "
		fi
	done < <(printf '%s\n' "${FONT_SPECS[@]}")
}
setup_fonts

S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cjk otf +ttf variable"

REQUIRED_USE="
	|| ( otf ttf )
	variable? ( ttf )
"

BDEPEND="app-arch/unzip"

src_prepare() {
	default

	# move into S and remove changing commit
	local src dest
	while IFS=$'\0' read -r -d $'\0' src; do
		dest="${S}/${src##*/}"
		dest="${dest//"-${COMMIT::8}"/}"
		cp --verbose --no-clobber --dereference \
			"${src}" "${dest}" || die
	done < <(find "${DISTDIR}" '(' -name '*.otf' -or -name '*.ttf' ')' -print0)
}

src_install() {
	FONT_SUFFIX="$(usev otf) $(usev ttf)"
	font_src_install
}
