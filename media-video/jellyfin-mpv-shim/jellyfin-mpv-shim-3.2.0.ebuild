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
	>=dev-python/jellyfin-apiclient-python-1.19.0[${PYTHON_USEDEP}]
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
	test? (
		media-video/ffmpeg
		media-video/mpv[libmpv]
	)
	${PYTHON_DEPS}
"

EPYTEST_PLUGINS=()

EPYTEST_IGNORE=(
	# integration tests are meant to run independent
	# via tests/integration/run_integration.py
	# but they're very flakey with virtx and often
	# just hang indefinitely
	tests/integration

	# e2e tests don't work because we have no Jellyfin server
	tests/e2e
)

EPYTEST_DESELECT=(
	# docs we don't care about here
	tests/test_doc_pointers.py::DocPointersTest
	tests/test_doc_sections.py::DocSectionsTest
	tests/test_doc_symbols.py::DocSymbolsTest

	# tests misc metadata files we install in python_install_all
	# the failure here is expected
	tests/test_window_identity.py::DesktopIdentityTest

	# misc failures; needs further investigation
	tests/test_themes.py::BadgeShadowTest::test_a_shadowed_badge_draws_no_pill_but_still_marks_the_corner
	tests/test_themes.py::BadgeShadowTest::test_super_dark_asks_for_shadows
	tests/test_themes.py::BadgeShadowTest::test_the_mark_stays_white_so_a_dark_accent_still_reads
	tests/test_themes.py::GradientAndHudAccentTest::test_the_translated_themes_carry_jf_webs_own_gradients
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
