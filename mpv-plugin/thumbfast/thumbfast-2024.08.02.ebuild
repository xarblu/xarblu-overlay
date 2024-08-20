# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="f1fdf10b17f394f2d42520d0e9bf22feaa20a9f4"

DESCRIPTION="High-performance on-the-fly thumbnailer for mpv "
HOMEPAGE="https://github.com/po5/thumbfast"
SRC_URI="https://github.com/po5/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

IUSE="+autoload"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="media-video/mpv"

S="${WORKDIR}/${PN}-${COMMIT}"

get_mpv_dir() {
	echo "/usr/$(get_libdir)/mpv/${PN}" || die
}

src_install() {
	insinto "$(get_mpv_dir)"
	doins thumbfast.lua
	if use autoload; then
		dosym "$(get_mpv_dir)/thumbfast.lua" "/etc/mpv/scripts/thumbfast.lua"
	fi

	# install sample conf
	insinto "/usr/share/${PN}"
	doins "${PN}.conf"

	# install docs (README)
	einstalldocs
}

pkg_postinst() {
	if ! use autoload; then
		elog
		elog "The plugin files have not been installed to /etc/mpv for autoloading."
		elog "Activate the autoload use flag. If you want them autoloaded."
		elog "If you want to manually configure them they're located in $(get_mpv_dir)."
		elog
	fi

	elog
	elog "A sample config has been installed to /usr/share/${PN}/${PN}.conf"
	elog
}
