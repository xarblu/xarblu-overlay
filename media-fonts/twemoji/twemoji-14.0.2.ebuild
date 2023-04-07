# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm font

FEDORA_RELEASE="3.fc38"

DESCRIPTION="A color emoji font with a flat visual style, designed and used by Twitter"
HOMEPAGE="https://twemoji.twitter.com"
SRC_URI="
	https://kojipkgs.fedoraproject.org/packages/twitter-twemoji-fonts/${PV}/${FEDORA_RELEASE}/noarch/twitter-twemoji-fonts-${PV}-${FEDORA_RELEASE}.noarch.rpm -> ${P}.rpm
	icons? ( https://github.com/twitter/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz )
"

LICENSE="Apache-2.0 CC-BY-4.0 MIT OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="icons"

RESTRICT="binchecks strip"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack "${P}.rpm"

	if use icons; then
		unpack "${P}.tar.gz"
	fi
}

src_compile() {
	if use icons; then
		pushd "${P}/assets/72x72"
			for png in *.png; do
				mv "${png}" emoji_u"${png//-/_}"
			done
		popd
		pushd "${P}/assets/svg"
			for svg in *.svg; do
				mv "${svg}" emoji_u"${svg//-/_}"
			done
		popd
	fi
}

src_install() {
	FONT_S="${WORKDIR}/usr/share/fonts/${PN}"

	# Don't lose fancy emoji icons
	if use icons; then
		insinto "/usr/share/icons/${PN}/72/emotes/"
		doins "${P}/assets/72x72/"*.png

		insinto "/usr/share/icons/${PN}/scalable/emotes/"
		doins "${P}/assets/svg/"*.svg
	fi

	FONT_SUFFIX="ttf"
	FONT_CONF=( "${FILESDIR}/75-${PN}.conf" )
	font_src_install
}
