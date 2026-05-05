# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 desktop pypi

DESCRIPTION="MPV Cast Client for Jellyfin"
HOMEPAGE="
	https://github.com/jellyfin/jellyfin-mpv-shim
	https://pypi.org/project/jellyfin-mpv-shim/
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE="discord shaders +systray"

DEPEND="
	>=dev-python/jellyfin-apiclient-python-1.12.0[${PYTHON_USEDEP}]
	>=dev-python/python-mpv-1.0.8[${PYTHON_USEDEP}]
	>=dev-python/python-mpv-jsonipc-1.2.2[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	media-video/mpv[libmpv]
	discord? ( dev-python/pypresence[${PYTHON_USEDEP}] )
	systray? (
		dev-python/pystray[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP},tk]
	)
	shaders? ( media-video/jellyfin-mpv-shim-default-shader-pack )
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND="${PYTHON_DEPS}"

src_prepare() {
	# move integration dir out of the way
	# so setuptools doesn't install it
	mv "jellyfin_mpv_shim/integration" "${WORKDIR}" || die

	distutils-r1_src_prepare
}

python_install() {
	distutils-r1_python_install

	# setup symlink for media-video/jellyfin-mpv-shim-default-shader-pack
	if use shaders; then
		dosym -r "/usr/share/jellyfin-mpv-shim-default-shader-pack" \
			"$(python_get_sitedir)/jellyfin_mpv_shim/default_shader_pack"
	fi
}

python_install_all() {
	distutils-r1_python_install_all

	#Install desktop stuff
	pushd "${WORKDIR}/integration" || die
		domenu com.github.iwalton3.jellyfin-mpv-shim.desktop
		local size icon
		for icon in *.png; do
			size="${icon#jellyfin-*}"
			size="${size%*.png}"
			newicon --size "${size}" "${icon}" com.github.iwalton3.jellyfin-mpv-shim.png
		done
		insinto /usr/share/metainfo/
		doins com.github.iwalton3.jellyfin-mpv-shim.appdata.xml
	popd || die
}
