# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Feature-rich minimalist proximity-based UI for MPV player"
HOMEPAGE="https://github.com/tomasklaen/uosc"

SRC_URI="
	https://github.com/tomasklaen/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/xarblu/xarblu-overlay/releases/download/distfiles/${P}-deps.tar.xz
"

IUSE="+autoload"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="media-video/mpv"

src_compile() {
	mkdir -p ./src/uosc/bin || die
	GOOS=linux ego build -ldflags "-s -w" -o ./src/uosc/bin/ziggy-linux ./src/ziggy/ziggy.go
}

src_install() {
	local MPV_INSTALL_DIR="/usr/$(get_libdir)/mpv/${PN}"

	insinto "${MPV_INSTALL_DIR}/scripts"
	doins -r "src/${PN}"

	insinto "${MPV_INSTALL_DIR}"
	doins -r "src/fonts"

	if use autoload; then
		local path dir file
		for path in "${ED}/${MPV_INSTALL_DIR}/"*/*; do
			dir="${path##"${ED}/${MPV_INSTALL_DIR}/"}"
			dir="${dir%/*}"
			file="${path##*/}"
			dosym "../../../${MPV_INSTALL_DIR#/}/${dir}/${file}" "/etc/mpv/${dir}/${file}"
		done
	fi
}

pkg_postinst() {
	MPV_INSTALL_DIR="/usr/$(get_libdir)/mpv/${PN}"
	if ! use autoload; then
		elog
		elog "The plugin files have not been installed to /etc/mpv for autoloading."
		elog "Activate the autoload use flag. If you want them autoloaded."
		elog "If you want to manually configure them they're located in ${MPV_INSTALL_DIR}."
		elog
	fi
}
