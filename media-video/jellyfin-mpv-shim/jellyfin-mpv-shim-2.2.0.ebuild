# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )
inherit distutils-r1 desktop

DESCRIPTION="MPV Cast Client for Jellyfin"
HOMEPAGE="https://github.com/jellyfin/jellyfin-mpv-shim"
SRC_URI="https://github.com/jellyfin/jellyfin-mpv-shim/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE="display-mirroring shaders +systray"

DEPEND="
	media-video/mpv[libmpv]
	>=dev-lang/python-3.6[tk]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/python-mpv[${PYTHON_USEDEP}]
	>=dev-python/python-mpv-jsonipc-1.1.9[${PYTHON_USEDEP}]
	>=dev-python/jellyfin-apiclient-python-1.8.1[${PYTHON_USEDEP}]
	systray? (
		dev-python/pystray[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
	)
	display-mirroring? (
		dev-python/jinja[${PYTHON_USEDEP}]
		dev-python/pywebview[${PYTHON_USEDEP}]
	)
	shaders? ( media-video/jellyfin-mpv-shim-default-shader-pack )
"
RDEPEND="${DEPEND}"
BDEPEND=""

shaders_symlink() {
	ln -sv "/usr/share/jellyfin-mpv-shim-default-shader-pack" \
		"${ED}/$(python_get_sitedir)/jellyfin_mpv_shim/default_shader_pack" || die
}

src_prepare() {
	#move integration dir out of the way
	#so setuptools doesn't install it
	mv ${S}/jellyfin_mpv_shim/integration ${WORKDIR}

	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install

	# Setup symlink to mpv-shim-default-shaders
	if use shaders; then
		python_foreach_impl shaders_symlink
	fi

	#Install desktop stuff
	pushd ${WORKDIR}/integration
		domenu com.github.iwalton3.jellyfin-mpv-shim.desktop
		for icon in *.png; do
			local size=${icon#jellyfin-*}
			size=${size%*.png}
			newicon --size ${size} ${icon} com.github.iwalton3.jellyfin-mpv-shim.png
		done
		insinto /usr/share/metainfo/
		doins com.github.iwalton3.jellyfin-mpv-shim.appdata.xml
	popd
}
