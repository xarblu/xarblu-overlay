# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 desktop

DESCRIPTION="MPV Cast Client for Jellyfin"
HOMEPAGE="
	https://github.com/jellyfin/jellyfin-mpv-shim
	https://pypi.org/project/jellyfin-mpv-shim/
"

# pypi tarball doesn't include all required test files
SRC_URI="
	https://github.com/jellyfin/jellyfin-mpv-shim/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE="discord shaders +systray"

DEPEND="
	>=dev-python/jellyfin-apiclient-python-1.18.0[${PYTHON_USEDEP}]
	>=dev-python/python-mpv-1.0.8[${PYTHON_USEDEP}]
	>=dev-python/python-mpv-jsonipc-1.4.0[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	media-video/mpv[libmpv]
	discord? ( dev-python/pypresence[${PYTHON_USEDEP}] )
	systray? ( dev-python/pystray[${PYTHON_USEDEP}] )
	shaders? ( media-video/jellyfin-mpv-shim-default-shader-pack )
	${PYTHON_DEPS}
"
RDEPEND="${DEPEND}"
BDEPEND="
	test? ( media-video/mpv )
	${PYTHON_DEPS}
"

EPYTEST_PLUGINS=()

# TODO: maybe make more fine-grained
# this currently deselect ~400 tests
# when only ~35 actually fail
EPYTEST_DESELECT=(
	# requires Jellyfin server
	tests/e2e/test_batch4_contracts.py
	tests/e2e/test_track_selection.py

	# requires X server (or GUI in general)
	tests/e2e/test_mpv_matrix.py
	tests/test_ui_select_key.py

	# requires audio server (I think?)
	tests/test_audio_settings.py

	# tests file we don't install (for every python impl)
	tests/test_doc_pointers.py
	tests/test_doc_sections.py
	tests/test_doc_symbols.py
	tests/test_window_identity.py

	# probably just not portage-sandbox compatible
	# needs further investigation
	tests/test_scene_snapshots.py
	tests/test_shell_settings.py
	tests/test_themes.py
	tests/test_thumbnail_cache.py
)

distutils_enable_tests pytest

src_prepare() {
	# move integration dir out of the way
	# so setuptools doesn't install it for each python impl
	mv "jellyfin_mpv_shim/integration" "${WORKDIR}" || die

	# fix test include
	sed -i \
		-e '/from test_mpv_options import/s/test_mpv_options/tests.test_mpv_options/' \
		tests/test_gamepad.py || die

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

	# install desktop integration stuff
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
