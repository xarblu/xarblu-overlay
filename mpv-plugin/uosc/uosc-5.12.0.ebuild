# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit go-module

DESCRIPTION="Feature-rich minimalist proximity-based UI for MPV player"
HOMEPAGE="https://github.com/tomasklaen/uosc"

SRC_URI="
	https://github.com/tomasklaen/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/xarblu/xarblu-overlay/releases/download/distfiles/${P}-deps.tar.xz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+autoload"

RDEPEND=">=media-video/mpv-0.33.0"

src_compile() {
	mkdir -p ./src/uosc/bin || die
	GOOS=linux ego build -ldflags "-s -w" -o ./src/uosc/bin/ziggy-linux ./src/ziggy/ziggy.go
}

src_install() {
	# shellcheck disable=SC2155
	local mpv_install_dir="/usr/$(get_libdir)/mpv/${PN}"

	insinto "${mpv_install_dir}/scripts"
	doins -r "src/${PN}"

	insinto "${mpv_install_dir}"
	doins -r "src/fonts"

	if use autoload; then
		local path dir file
		for path in "${ED}/${mpv_install_dir}/"*/*; do
			dir="${path##"${ED}/${mpv_install_dir}/"}"
			dir="${dir%/*}"
			file="${path##*/}"
			dosym -r "${mpv_install_dir}/${dir}/${file}" "/etc/mpv/${dir}/${file}"
		done
	fi
}

pkg_postinst() {
	# shellcheck disable=SC2155
	local mpv_install_dir="/usr/$(get_libdir)/mpv/${PN}"

	if ! use autoload; then
		elog
		elog "The plugin files have not been installed to /etc/mpv for autoloading."
		elog "Activate the autoload use flag. If you want them autoloaded."
		elog "If you want to manually configure them they're located in ${mpv_install_dir}."
		elog
	fi
}
