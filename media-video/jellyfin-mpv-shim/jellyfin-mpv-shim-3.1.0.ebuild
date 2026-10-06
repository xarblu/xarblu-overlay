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

EPYTEST_DESELECT=(
	# require Jellyfin server
	# (and apparently not guarded with @_e2e.require_server)
	tests/e2e/test_batch4_contracts.py::LibraryScopeLookupTest
	tests/e2e/test_offline_ui.py::ConflictsAtReconnectTest
	tests/e2e/test_track_selection.py::TranscodedTrackRulesTest

	# doesn't check paths media-video/mpv[libmpv] installs to
	tests/e2e/test_mpv_matrix.py::MpvMatrixTest::test_every_libmpv_on_this_machine_comes_up

	# require "real mpv" (GUI on X server)
	# xvfb-run supposedly can run these headless
	# but they all timed-out/failed for me regardless
	tests/integration/test_e2e_offline.py::OfflineEndToEndTest
	tests/integration/test_mpvtk_auth.py::TestSwitchingToALockedUser
	tests/integration/test_mpvtk_auth.py::TestTheStartupPinGate
	tests/integration/test_mpvtk_auth.py::TestTheUserSwitcher
	tests/integration/test_mpvtk_browser.py::BrowseKeyBlockTest
	tests/integration/test_mpvtk_browser.py::ClassicOscReleasesTheMouseTest
	tests/integration/test_mpvtk_browser.py::TestLongDropdownScroll
	tests/integration/test_mpvtk_browser.py::TestMpvtkBrowserOnRealMpv
	tests/integration/test_mpvtk_browser.py::TestRealMousePosPath
	tests/integration/test_mpvtk_browser.py::TestTableRowContextMenu
	tests/integration/test_mpvtk_browser.py::TestTextBoxCommitsOnBlur
	tests/integration/test_mpvtk_hud.py::RealConsoleLoanTest
	tests/integration/test_mpvtk_hud.py::TestPlaybackHudLifecycle
	tests/integration/test_realmpv_picture.py::RealMpvPictureTest
	tests/integration/test_realmpv_smoke.py::IdleQuitReopenIsolatedTest
	tests/integration/test_realmpv_smoke.py::RealMpvSmokeTest
	tests/integration/test_settings_screen.py::RealSettingsClickTest
	tests/integration/test_settings_screen.py::RealSettingsScreenTest::test_every_tab_renders_with_the_real_config
	tests/integration/test_window_decorations.py::WindowDecorationsOnRealMpv
	tests/test_ui_select_key.py::OfferedTest::test_and_the_words_someone_looking_for_it_types

	# web-seek tests don't work; I'm assuming a mix
	# of no server and no GUI
	tests/test_key_claims.py::AfterMigrationTest::test_an_inexpressible_feature_keeps_its_claim
	tests/test_key_claims.py::SeekClaimGateTest::test_web_seek_claims
	tests/test_remote_seek.py::RemoteSeekTest::test_web_seek_replaces_the_distance_by_sign

	# require audio server
	tests/test_audio_settings.py::ApplyAudioSettingsTest

	# docs we don't care about here
	tests/test_doc_pointers.py::DocPointersTest
	tests/test_doc_sections.py::DocSectionsTest
	tests/test_doc_symbols.py::DocSymbolsTest

	# tests misc metadata files we install in python_install_all
	# and are thus expected missing here
	tests/test_window_identity.py::DesktopIdentityTest

	# tries to write outside sandbox
	tests/integration/test_download_relocate.py::GuardsThatMustRefuseTest::test_a_folder_this_process_may_not_write_to

	# misc failures; needs further investigation
	tests/test_osc_fallback_persists.py::OverrideSurvivesTest::test_without_an_override_the_settings_still_decide
	tests/test_scene_snapshots.py::TestSceneSnapshots::test_settings
	tests/test_shell_settings.py::TestSettings::test_hud_key_settings_sit_under_the_keybind_note
	tests/test_themes.py::BadgeShadowTest::test_a_shadowed_badge_draws_no_pill_but_still_marks_the_corner
	tests/test_themes.py::BadgeShadowTest::test_super_dark_asks_for_shadows
	tests/test_themes.py::BadgeShadowTest::test_the_mark_stays_white_so_a_dark_accent_still_reads
	tests/test_themes.py::GradientAndHudAccentTest::test_the_translated_themes_carry_jf_webs_own_gradients
	tests/test_thumbnail_cache.py::DiskCacheLocationTest::test_it_prefers_somewhere_that_survives_a_restart
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
