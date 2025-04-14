# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font desktop

DESCRIPTION="A color emoji font with a flat visual style"
HOMEPAGE="https://github.com/jdecked/twemoji"
# prebuilt font from AUR package
# https://aur.archlinux.org/packages/ttf-twemoji
# JoeBlakeB/ttf-twemoji-aur/releases -> ttf file
# JoeBlakeB/ttf-twemoji-aur/archive -> fontconfig file
# jdecked/twemoji -> icons
SRC_URI="
	https://github.com/JoeBlakeB/ttf-${PN}-aur/releases/download/${PV}/${P^}.ttf
	https://github.com/JoeBlakeB/ttf-${PN}-aur/archive/${PV}.tar.gz -> ${P}-aur.tar.gz
	icons? (
		https://github.com/jdecked/${PN}/archive/v${PV}.tar.gz
			-> ${P}-icons.tar.gz
	)
"

LICENSE="Apache-2.0 CC-BY-4.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="icons"

src_prepare() {
	default
	if use icons; then
		pushd "assets/72x72" || die
			for png in *.png; do
				mv "${png}" emoji_u"${png//-/_}" || die
			done
		popd || die
		pushd "assets/svg" || die
			for svg in *.svg; do
				mv "${svg}" emoji_u"${svg//-/_}" || die
			done
		popd || die
	fi

	mkdir fonts-install
	cp -t fonts-install "${DISTDIR}/${P^}.ttf" || die
}

src_install() {
	# don't lose fancy emoji icons
	if use icons; then
		doicon --size 72 --context emotes --theme "${PN}" assets/72x72
		doicon --size scalable --context emotes --theme "${PN}" assets/svg
	fi

	FONT_S="${S}/fonts-install"
	FONT_SUFFIX="ttf"
	FONT_CONF=( "${WORKDIR}/ttf-${PN}-aur-${PV}/AUR/75-${PN}.conf" )
	font_src_install
}
