# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Feature-rich minimalist proximity-based UI for MPV player"
HOMEPAGE="https://github.com/tomasklaen/uosc"
SRC_URI="https://github.com/tomasklaen/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

IUSE="+autoload"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	media-video/mpv:=
"
RDEPEND="${DEPEND}"

src_install() {
	MPV_INSTALL_DIR="/usr/$(get_libdir)/mpv/${PN}"
	for dir in {scripts,fonts}; do
		pushd ${dir}
			insinto "${MPV_INSTALL_DIR}/${dir}"
			doins -r *
			if use autoload; then
				for file in *; do
					dosym "../../..${MPV_INSTALL_DIR}/${dir}/${file}" "/etc/mpv/${dir}/${file}"
				done
			fi
		popd
	done
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
