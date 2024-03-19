# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A color emoji font with a flat visual style"
HOMEPAGE="https://github.com/jdecked/twemoji"
SRC_URI="
	https://github.com/JoeBlakeB/ttf-twemoji-aur/releases/download/${PV}/${PN^}-${PV}.ttf
	icons? (
		https://github.com/jdecked/${PN}/archive/v${PV}.tar.gz
			-> ${P}.tar.gz
	)
"

LICENSE="Apache-2.0 CC-BY-4.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="icons"

RESTRICT="binchecks strip"

src_unpack() {
	if use icons; then
		unpack "${P}.tar.gz"
	fi
}

src_prepare() {
	default
	if use icons; then
		pushd "${WORKDIR}/${P}/assets/72x72" || die
			for png in *.png; do
				mv "${png}" emoji_u"${png//-/_}" || die
			done
		popd || die
		pushd "${WORKDIR}/${P}/assets/svg" || die
			for svg in *.svg; do
				mv "${svg}" emoji_u"${svg//-/_}" || die
			done
		popd || die
	fi
}

src_install() {
	# don't lose fancy emoji icons
	if use icons; then
		insinto "/usr/share/icons/${PN}/72x72/emotes/"
		doins assets/72x72/*.png
		insinto "/usr/share/icons/${PN}/scalable/emotes/"
		doins assets/svg/*.svg
	fi

	FONT_S="${DISTDIR}"
	FONT_SUFFIX="ttf"
	FONT_CONF=( "${FILESDIR}/75-${PN}.conf" )
	font_src_install
}
