# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font check-reqs

# curl https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v${PV}/bin/scripts/lib/fonts.json |
# jq --raw-output '.fonts[] | "\"\(.folderName):\(.licenseId)\""'
FONTS=(
	"0xProto:OFL-1.1-no-RFN"
	"3270:BSD-3-Clause"
	"Agave:MIT"
	"AnonymousPro:OFL-1.1-RFN"
	"Arimo:Apache-2.0"
	"AurulentSansMono:OFL-1.1-no-RFN"
	"BigBlueTerminal:CC-BY-SA-4.0"
	"BitstreamVeraSansMono:Bitstream-Vera"
	"IBMPlexMono:OFL-1.1-RFN"
	"CascadiaCode:OFL-1.1-RFN"
	"CascadiaMono:OFL-1.1-RFN"
	"CodeNewRoman:OFL-1.1-no-RFN"
	"ComicShannsMono:MIT"
	"CommitMono:OFL-1.1-no-RFN"
	"Cousine:Apache-2.0"
	"D2Coding:OFL-1.1-no-RFN"
	"DaddyTimeMono:OFL-1.1-no-RFN"
	"DepartureMono:OFL-1.1-no-RFN"
	"DejaVuSansMono:Bitstream-Vera"
	"DroidSansMono:Apache-2.0"
	"EnvyCodeR:OFL-1.1-RFN"
	"FantasqueSansMono:OFL-1.1-no-RFN"
	"FiraCode:OFL-1.1-no-RFN"
	"FiraMono:OFL-1.1-no-RFN"
	"GeistMono:OFL-1.1-no-RFN"
	"Go-Mono:BSD-3-Clause-Clear"
	"Gohu:WTFPL"
	"Hack:Bitstream-Vera AND MIT"
	"Hasklig:OFL-1.1-RFN"
	"HeavyData:LicenseRef-VicFieger"
	"Hermit:OFL-1.1-RFN"
	"iA-Writer:OFL-1.1-RFN"
	"Inconsolata:OFL-1.1-no-RFN"
	"InconsolataGo:OFL-1.1-no-RFN"
	"InconsolataLGC:OFL-1.1-no-RFN"
	"IntelOneMono:OFL-1.1-RFN"
	"Iosevka:OFL-1.1-no-RFN"
	"IosevkaTerm:OFL-1.1-no-RFN"
	"IosevkaTermSlab:OFL-1.1-no-RFN"
	"JetBrainsMono:OFL-1.1-no-RFN"
	"Lekton:OFL-1.1-no-RFN"
	"LiberationMono:OFL-1.1-RFN"
	"Lilex:OFL-1.1-no-RFN"
	"MartianMono:OFL-1.1-no-RFN"
	"Meslo:Apache-2.0"
	"Monaspace:OFL-1.1-RFN"
	"Monofur:LicenseRef-Monofur"
	"Monoid:MIT OR OFL-1.1-no-RFN"
	"Mononoki:OFL-1.1-RFN"
	"MPlus:OFL-1.1-no-RFN"
	"Noto:OFL-1.1-no-RFN"
	"OpenDyslexic:Bitstream-Vera"
	"Overpass:OFL-1.1-no-RFN or LGPL-2.1-only"
	"ProFont:MIT"
	"ProggyClean:MIT"
	"Recursive:OFL-1.1-no-RFN"
	"RobotoMono:Apache-2.0"
	"ShareTechMono:OFL-1.1-RFN"
	"SourceCodePro:OFL-1.1-RFN"
	"SpaceMono:OFL-1.1-no-RFN"
	"NerdFontsSymbolsOnly:MIT"
	"Terminus:OFL-1.1-RFN"
	"Tinos:Apache-2.0"
	"Ubuntu:LicenseRef-UbuntuFont"
	"UbuntuMono:LicenseRef-UbuntuFont"
	"UbuntuSans:LicenseRef-UbuntuFont"
	"VictorMono:OFL-1.1-no-RFN"
	"ZedMono:OFL-1.1-no-RFN"
)

# translate licenses to gentoos names
gentoo_license() {
	local name names
	# bash shenanigans since we can't sed here
	names="${1}"
	names="${names// AND / }"
	names="${names// OR / }"
	names="${names// and / }"
	names="${names// or / }"
	for name in ${names}; do
		case "$name" in
			OFL-1.1*) echo OFL-1.1;;
			BSD*) echo BSD;;
			MIT) echo MIT;;
			Apache-2.0) echo Apache-2.0;;
			CC-BY-SA-4.0) echo CC-BY-SA-4.0;;
			Bitstream-Vera) echo BitstreamVera;;
			WTFPL) echo WTFPL-2;;
			LicenseRef-VicFieger) echo Vic-Fieger-License;;
			LicenseRef-Monofur) echo Monofur;;
			LGPL-2.1*) echo LGPL-2.1;;
			LicenseRef-UbuntuFont) echo UbuntuFontLicense-1.0;;
			*) eqawarn "Unknown license: \"$1\"\nUpdate gentoo_license";;
		esac
	done
}

font_vars() {
	local base_uri="https://github.com/ryanoasis/nerd-fonts/releases/download/v${PV}"
	local font name license
	for font in "${FONTS[@]}"; do
		name="${font%:*}"
		license="${font#*:}"
		FONT_SRC_URI+=" ${name,,}? ( ${base_uri}/${name}.tar.xz -> ${PN}-${name}-${PV}.tar.xz )"
		FONT_LICENSE+=" ${name,,}? ( $(gentoo_license "${license}") )"
		FONT_IUSE+=" ${name,,}"
	done
}
font_vars

DESCRIPTION="Nerd Fonts is a project that patches fonts with a high number of glyphs"
HOMEPAGE="https://www.nerdfonts.com/"

SRC_URI="${FONT_SRC_URI}"
S="${WORKDIR}"
FONT_S="${S}"

LICENSE="${FONT_LICENSE}"
IUSE="${FONT_IUSE}"
REQUIRED_USE="|| ( ${FONT_IUSE} )"

SLOT="0"
KEYWORDS="~amd64 ~x86"

approx_fonts_disk_reqs() {
	# all fonts combined need ~8G
	# (according to portage "final size of build dir")
	# let's assume that's distributed somewhat evenly
	local avgsize font fontcount
	avgsize=$(( 8000 / ${#FONTS[@]} ))
	fontcount=0
	for font in ${FONT_IUSE}; do
		use "${font}" && fontcount=$(( fontcount + 1 ))
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
