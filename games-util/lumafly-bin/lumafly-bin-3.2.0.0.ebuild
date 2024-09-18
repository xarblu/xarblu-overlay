# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

DESCRIPTION="A cross platform mod manager for Hollow Knight written in Avalonia"
HOMEPAGE="https://themulhima.github.io/Lumafly/"
SRC_URI="
	https://github.com/TheMulhima/Lumafly/releases/download/v${PV}/Lumafly-Linux.zip -> ${P}.zip
	https://raw.githubusercontent.com/TheMulhima/Lumafly/v${PV}/Lumafly/Assets/Lumafly.png -> ${P}.png
"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	app-arch/unzip
	virtual/imagemagick-tools[png]
"

# causes arithmetic overflow while reading bundle
RESTRICT="strip"

QA_PREBUILT="usr/bin/Lumafly"

src_prepare() {
	# resize icon to standard sizes
	for size in 16 22 24 32 36 48 64 72 96 128 192 256 512; do
		einfo "Generating icon for size ${size}"
		magick "${DISTDIR}/${P}.png" -resize "${size}" "icon-${size}.png" || die
	done
	default
}

src_install() {
	for size in 16 22 24 32 36 48 64 72 96 128 192 256 512; do
		newicon -s "${size}" "icon-${size}.png" "Lumafly.png"
	done

	domenu "${FILESDIR}/Lumafly.desktop"

	dobin Lumafly
}
