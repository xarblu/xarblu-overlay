# Copyright 2019-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit font

DESCRIPTION="The package of IBM's typeface"
HOMEPAGE="https://github.com/IBM/plex"

# spec for each relevant font file in the repo within the packages/ dir
# we will download them individually because archives of the entire repo
# are over 1GB even when compressed
# format: <use>:<dir>:<family>:<types>:<hinted>:<tier>:<ref>
# use: use flag guardig the font e.g. cjk
# dir: font root dir e.g. ibm-mono
# name: font name e.g. IBMPlexMono
# types: comma seperated available types otf,ttf
# hinted: comma separated types that are split in hinted/unhinted
# tier: "tier" of font
#       1 -> only Regular
#       8 -> 8 variants
#       16 -> 16 variants
# ref: GIT commit of the last update for a family (to avoid large re-fetch)
# shellcheck disable=SC2054
FONT_SPECS=(
	-:plex-math:IBMPlexMath:otf,ttf::1:bb3ab6404e1881ea286f8742dc839e09057db6dd
	-:plex-mono:IBMPlexMono:otf,ttf::16:bb3ab6404e1881ea286f8742dc839e09057db6dd
	-:plex-sans-arabic:IBMPlexSansArabic:otf,ttf::8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	-:plex-sans-condensed:IBMPlexSansCondensed:otf,ttf::16:bb3ab6404e1881ea286f8742dc839e09057db6dd
	-:plex-sans-devanagari:IBMPlexSansDevanagari:otf,ttf::8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	-:plex-sans-hebrew:IBMPlexSansHebrew:otf,ttf::8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	cjk:plex-sans-jp:IBMPlexSansJP:otf,ttf:otf,ttf:8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	cjk:plex-sans-kr:IBMPlexSansKR:otf,ttf:ttf:8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	cjk:plex-sans-sc:IBMPlexSansSC:otf,ttf:otf,ttf:8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	cjk:plex-sans-tc:IBMPlexSansTC:otf,ttf:otf,ttf:8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	-:plex-sans-thai-looped:IBMPlexSansThaiLooped:otf,ttf::8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	-:plex-sans-thai:IBMPlexSansThai:otf,ttf::8:bb3ab6404e1881ea286f8742dc839e09057db6dd
	variable:plex-sans-variable:'IBM Plex Sans Var':ttf::variable:bb3ab6404e1881ea286f8742dc839e09057db6dd
	-:plex-sans:IBMPlexSans:otf,ttf::16:bb3ab6404e1881ea286f8742dc839e09057db6dd
	variable:plex-serif-variable:'IBM Plex Serif Var':ttf::variable:770f2077bb8cb12a3a20bcefc8be9dd2ed985908
	-:plex-serif:IBMPlexSerif:otf,ttf::16:434af578549afcfdabd281f386e0ff7314fd20b0
)

setup_fonts() {
	local font_use font_dir font_family font_types font_hinted font_tier commit
	local url
	while IFS=':' read -r font_use font_dir font_family font_types font_hinted font_tier commit; do
		url="https://github.com/IBM/plex/raw/${commit}/packages/${font_dir}/fonts/complete"

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
							-> ${font_family// /_}-${font_variant}-Hinted-${commit::8}.${font_type}
					) "
					SRC_URI+=" ${font_type}? (
						${url}/${font_type}/unhinted/${font_family// /%20}-${font_variant}.${font_type}
							-> ${font_family// /_}-${font_variant}-Unhinted-${commit::8}.${font_type}
					) "
				else
					SRC_URI+=" ${font_type}? (
						${url}/${font_type}/${font_family// /%20}-${font_variant}.${font_type}
							-> ${font_family// /_}-${font_variant}-${commit::8}.${font_type}
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

src_prepare() {
	default

	# move into S and remove changing commit
	local src dest file ext
	while IFS=$'\0' read -r -d $'\0' src; do
		# <font>-<commit[8]>.<ext> -> <font>.<ext>
		file="${src##*/}"
		ext="${file##*.}"
		file="${file%.*}"
		file="${file%-????????}.${ext}"
		dest="${S}/${file}"
		cp --verbose --no-clobber --dereference "${src}" "${dest}" || die
	done < <(find "${DISTDIR}" '(' -name '*.otf' -or -name '*.ttf' ')' -print0)
}

src_install() {
	FONT_SUFFIX="$(usev otf) $(usev ttf)"
	font_src_install
}
