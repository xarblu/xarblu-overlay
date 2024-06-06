# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1 desktop

DESCRIPTION="MPV Cast Client for Jellyfin"
HOMEPAGE="https://github.com/jellyfin/jellyfin-mpv-shim"
SRC_URI="https://github.com/jellyfin/jellyfin-mpv-shim/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE="shaders +systray"

DEPEND="
	media-video/mpv[libmpv]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/python-mpv[${PYTHON_USEDEP}]
	>=dev-python/python-mpv-jsonipc-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/jellyfin-apiclient-python-1.9.2[${PYTHON_USEDEP}]
	systray? (
		dev-python/pystray[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		$(python_gen_impl_dep 'tk')
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

	# package the shaders seperately
	# only install integrations once
	sed -i \
		-e "/jellyfin_mpv_shim\.default_shader_pack/d" \
		-e "/jellyfin_mpv_shim\.default_shader_pack\.shaders/d" \
		-e "/jellyfin_mpv_shim\.integration/d" \
		setup.py || die

	distutils-r1_src_prepare
}

python_install() {
	# setup symlink for media-video/jellyfin-mpv-shim-default-shader-pack
	if use shaders; then
		dosym "/usr/share/jellyfin-mpv-shim-default-shader-pack" \
			"$(python_get_sitedir)/jellyfin_mpv_shim/default_shader_pack"
	fi

	distutils-r1_python_install
}

python_install_all() {
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

	distutils-r1_python_install_all
}
