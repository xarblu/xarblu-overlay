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
	cjk:sans-sc
	cjk:sans-tc
	-:sans-thai-looped
	-:sans-thai
	-:sans
	-:serif
)

setup_variants() {
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

src_prepare() {
	default

	# staging area for sane install path
	local src dest
	while IFS= read -r -d $'\0' src; do
		name="${src#./}"
		name="${name%%fonts/*}"
		dest="${name}/${src#./*/fonts/complete/}"
		mkdir -p "staging/${dest}" || die
		mv -v -t "staging/${dest}" "${src}"/* || die
	done < <(find . "(" -type d -and "(" -name otf -or -name ttf ")" ")" -print0)
}

src_install() {
	# enter staging area to not have path in install location
	cd staging || die

	# select types and
	FONT_SUFFIX="$(usev otf) $(usev ttf)"
	FONT_S=()
	local dir
	while IFS= read -r -d $'\0' dir; do
		# skip dir when not USE
		case "${dir}" in
			*/otf*) use otf || continue ;;
			*/ttf*) use ttf || continue ;;
		esac
		# require font file to be present
		if [[ -z "$(find "${dir}" -maxdepth 1 -type f -name "*.otf" -or -name "*.ttf")" ]]; then
			continue
		fi
		einfo "Adding ${dir} to FONT_S"
		FONT_S+=( "${dir}" )
	done < <(find . -type d -print0)

	einfo "Final FONT_S: ${FONT_S[*]}"

	font_src_install
}
