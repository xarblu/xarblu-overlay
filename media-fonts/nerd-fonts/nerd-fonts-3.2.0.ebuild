# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font check-reqs

DESCRIPTION="Nerd Fonts is a project that patches fonts with a high number of glyphs"
HOMEPAGE="https://www.nerdfonts.com/"

# base licenses for patched fonts
# (glyphs etc)
LICENSE="
	OFL-1.1
	CC-BY-SA-4.0
	MIT
	Apache-2.0
"
SLOT="0"
KEYWORDS="~amd64 ~x86"

FONTS=(
	0xproto
	3270
	Agave
	AnonymousPro
	Arimo
	AurulentSansMono
	BigBlueTerminal
	BitstreamVeraSansMono
	CascadiaCode
	CascadiaMono
	CodeNewRoman
	ComicShannsMono
	CommitMono
	Cousine
	D2Coding
	DaddyTimeMono
	DejaVuSansMono
	DroidSansMono
	EnvyCodeR
	FantasqueSansMono
	FiraCode
	FiraMono
	GeistMono
	Go-Mono
	Gohu
	Hack
	Hasklig
	HeavyData
	Hermit
	iA-Writer
	IBMPlexMono
	Inconsolata
	InconsolataGo
	InconsolataLGC
	IntelOneMono
	Iosevka
	IosevkaTerm
	IosevkaTermSlab
	JetBrainsMono
	Lekton
	LiberationMono
	Lilex
	MartianMono
	Meslo
	Monaspace
	Monofur
	Monoid
	Mononoki
	MPlus
	NerdFontsSymbolsOnly
	Noto
	OpenDyslexic
	Overpass
	ProFont
	ProggyClean
	Recursive
	RobotoMono
	ShareTechMono
	SourceCodePro
	SpaceMono
	Terminus
	Tinos
	Ubuntu
	UbuntuMono
	VictorMono
	ZedMono
)

use_src_uri() {
	local base_uri="https://github.com/ryanoasis/nerd-fonts/releases/download/v${PV}"
	local font
	for font in "${FONTS[@]}"; do
		IUSE="${IUSE} ${font,,}"
		SRC_URI="${SRC_URI} ${font,,}? ( ${base_uri}/${font}.tar.xz -> ${PN}-${font}-${PV}.tar.xz )"
		# extra licenses, only those not already covered
		case "${font}" in
			BitstreamVeraSansMono) LICENSE="${LICENSE# } ${font,,}? ( BitstreamVera )" ;;
			Gohu) LICENSE="${LICENSE} ${font,,}? ( WTFPL-2 )" ;;
			# "Go project license", I guess same as dev-lang/go
			Go-Mono) LICENSE="${LICENSE} ${font,,}? ( BSD )" ;;
			HeavyData) LICENSE="${LICENSE} ${font,,}? ( Vic-Fieger-License )" ;;
			Monofur) LICENSE="${LICENSE} ${font,,}? ( Monofur )" ;;
			Ubuntu|UbuntuMono) LICENSE="${LICENSE} ${font,,}? ( UbuntuFontLicense-1.0 )" ;;
		esac
	done
}
use_src_uri

REQUIRED_USE="|| ( ${FONTS[*],,} )"

S="${WORKDIR}"
FONT_S="${S}"

approx_fonts_disk_reqs() {
	# all fonts combined need ~8G
	# (according to portage "final size of build dir")
	# let's assume that's distributed somewhat evenly
	local avgsize font fontcount
	avgsize=$(( 8000 / ${#FONTS[@]} ))
	fontcount=0
	for font in "${FONTS[@]}"; do
		use "${font,,}" && fontcount=$(( fontcount + 1 ))
	done
	echo "$(( avgsize * fontcount ))M"
}

pkg_setup() {
	CHECKREQS_DISK_BUILD="$(approx_fonts_disk_reqs)"
	CHECKREQS_DISK_USR="${CHECKREQS_DISK_BUILD}"
	check-reqs_pkg_setup
}

pkg_pretend() {
	CHECKREQS_DISK_BUILD="$(approx_fonts_disk_reqs)"
	CHECKREQS_DISK_USR="${CHECKREQS_DISK_BUILD}"
	check-reqs_pkg_pretend
}

src_install() {
	local suffix
	for suffix in ttf otf; do
		if ( find . -name "*.${suffix}" | read ); then
			FONT_SUFFIX="${FONT_SUFFIX} ${suffix}"
		fi
	done
	font_src_install
}
