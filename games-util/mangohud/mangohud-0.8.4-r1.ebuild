# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit toolchain-funcs flag-o-matic python-r1 desktop meson-multilib

DESCRIPTION="Vulkan and OpenGL overlay for monitoring FPS, sensors, system load and more"
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

MY_PV=$(ver_cut 1-3)
[[ -n "$(ver_cut 4-)" ]] && MY_PV_REV="-$(ver_cut 4-)"

# required subprojects
declare -A subprojectv=(
	[vulkan-headers]="1.4.346"
	[vulkan-utility-libraries]="1.4.346"
	[imgui]="1.91.6"
	[implot]="0.16"
	[implot_meson]="0.16-1"
)

WRAP_SRC="https://github.com/mesonbuild/wrapdb/releases/download"
SRC_URI="
	https://github.com/flightlessmango/MangoHud/archive/v${MY_PV}${MY_PV_REV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/KhronosGroup/Vulkan-Headers/archive/v${subprojectv[vulkan-headers]}.tar.gz
		-> vulkan-headers-${subprojectv[vulkan-headers]}.tar.gz
	https://github.com/KhronosGroup/Vulkan-Utility-Libraries/archive/v${subprojectv[vulkan-utility-libraries]}.tar.gz
		-> vulkan-utility-libraries-${subprojectv[vulkan-utility-libraries]}.tar.gz
	https://github.com/ocornut/imgui/archive/v${subprojectv[imgui]}.tar.gz
		-> imgui-${subprojectv[imgui]}.tar.gz
	https://github.com/epezent/implot/archive/v${subprojectv[implot]}.tar.gz
		-> imgui-${subprojectv[implot]}.tar.gz
	${WRAP_SRC}/implot_${subprojectv[implot_meson]}/implot_${subprojectv[implot_meson]}_patch.zip
"

S="${WORKDIR}/MangoHud-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+dbus debug mangoapp mangoplot test wayland video_cards_nvidia +X xnvctrl"

REQUIRED_USE="
	|| ( X wayland )
	mangoapp? ( X )
	xnvctrl? ( video_cards_nvidia X )
	${PYTHON_REQUIRED_USE}
"

# TODO: remove once dev-python/matplotlib
# has py3.15 support
REQUIRED_USE+=" mangoplot? ( !python_targets_python3_15 )"

RESTRICT="!test? ( test )"

# shellcheck disable=SC2016
BDEPEND="
	app-arch/unzip
	test? ( dev-util/cmocka[${MULTILIB_USEDEP}] )
	$(python_gen_any_dep 'dev-python/mako[${PYTHON_USEDEP}]')
	${PYTHON_DEPS}
"

DEPEND="
	dev-libs/spdlog:=[${MULTILIB_USEDEP}]
	dev-util/glslang[${MULTILIB_USEDEP}]
	media-libs/libglvnd[${MULTILIB_USEDEP}]
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	x11-libs/libdrm[${MULTILIB_USEDEP}]
	x11-libs/libxkbcommon[${MULTILIB_USEDEP}]
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	mangoapp? (
		media-libs/glfw[-wayland-only(-),X(+)]
	)
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[${MULTILIB_USEDEP}]
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? (
		>=dev-libs/wayland-1.11[${MULTILIB_USEDEP}]
	)
	X? (
		x11-libs/libX11[${MULTILIB_USEDEP}]
	)
	${PYTHON_DEPS}
"

# shellcheck disable=SC2016
RDEPEND="
	mangoapp? ( gui-wm/gamescope )
	mangoplot? (
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
	)
	${DEPEND}
"

python_check_deps() {
	python_has_version -b "dev-python/mako[${PYTHON_USEDEP}]"
}

pkg_setup() {
	python_setup
}

src_unpack() {
	default
	[[ -n "${MY_PV_REV}" ]] && ( mv "${WORKDIR}/MangoHud-${MY_PV}${MY_PV_REV}" "${WORKDIR}/MangoHud-${PV}" || die )

	# install subprojects
	local projects=(
		"Vulkan-Headers-${subprojectv[vulkan-headers]}"
		"Vulkan-Utility-Libraries-${subprojectv[vulkan-utility-libraries]}"
		"imgui-${subprojectv[imgui]}"
		"implot-${subprojectv[implot]}"
	)

	local subproject
	for subproject in "${projects[@]}"; do
		einfo "Installing subproject ${subproject}"
		mv -vt "${S}/subprojects/" "${WORKDIR}/${subproject}" || die "Couldn't install ${subproject}"
	done

	# inject meson.build files
	for subproject in "${S}/subprojects/packagefiles"/*; do
		case "${subproject}" in
			*/imgui-${subprojectv[imgui]})
				mv -vt "${S}/subprojects/imgui-${subprojectv[imgui]}" \
					"${subproject}/meson.build" \
					"${subproject}/meson_options.txt" || die
				;;
			*/vulkan-headers)
				mv -vt "${S}/subprojects/Vulkan-Headers-${subprojectv[vulkan-headers]}" \
					"${subproject}/meson.build" || die
				;;
			*/vulkan-utility-libraries)
				mv -vt "${S}/subprojects/Vulkan-Utility-Libraries-${subprojectv[vulkan-utility-libraries]}" \
					"${subproject}/meson.build" || die
				;;
			*)
				die "Unknown subproject in packagefiles: ${subproject}"
				;;
		esac
	done
}

src_prepare() {
	# set version since we don't have git tags
	sed -i -e "/^project('MangoHud',$/,/^)$/s/version : '.*'/version : '${MY_PV}${MY_PV_REV}'/" \
		meson.build || die

	# we expect system spdlog so disallow the fallback to bundled
	sed -i -e '/^spdlog_dep/s/required: false/required: true/' meson.build || die

	# mangohud by default statically links libstdc++
	# dynamically linked libc++ works just fine though
	if [[ "$(tc-get-cxx-stdlib)" == "libc++" ]]; then
		eapply "${FILESDIR}/0.8.0_rc1-libcxx.patch"
	fi

	# https://github.com/flightlessmango/MangoHud/issues/1240
	# lld throws an error, mold just a warning, bfd doesn't care
	if [[ "$(tc-getLD)" == "ld.lld" ]]; then
		append-ldflags "-Wl,--undefined-version"
	fi

	default
}

# shellcheck disable=SC2207
multilib_src_configure() {
	local emesonargs=(
		-Duse_system_spdlog=enabled
		-Dappend_libdir_mangohud=false
		# QA: install docs in src_install to ensure FHS/Gentoo policy
		# also avoids dev-libs/appstream test dep
		-Dinclude_doc=false
		$(meson_feature video_cards_nvidia with_nvml)
		$(meson_feature xnvctrl with_xnvctrl)
		$(meson_feature X with_x11)
		$(meson_feature wayland with_wayland)
		$(meson_feature dbus with_dbus)
		$(meson_feature test tests)
		# no extra deps but afaik only relevant on arm64
		$(meson_use arm64 with_fex)
	)

	# the tools are meant for the native ABI only
	# and this avoids a ton of useless 32bit libs
	if multilib_is_native_abi; then
		emesonargs+=(
			$(meson_use mangoapp mangoapp)
			# mangohudctl only makes sense with mangoapp
			$(meson_use mangoapp mangohudctl)
			$(meson_feature mangoplot mangoplot)
		)
	fi

	meson_src_configure
}

multilib_src_install_all() {
	# extra stuff under data/ (usually controlled by -Dinclude_doc)
	insinto /usr/share/metainfo
	doins data/io.github.flightlessmango.mangohud.metainfo.xml
	doicon -s scalable data/io.github.flightlessmango.mangohud.svg
	doman data/mangohud.1
	use mangoapp && doman data/mangoapp.1
	newdoc data/MangoHud.conf MangoHud.conf.example
	newdoc data/presets.conf presets.conf.example
}

pkg_postinst() {
	if ! use xnvctrl; then
		elog ""
		elog "If mangohud can't get GPU load, or other GPU information,"
		elog "and you may have an older Nvidia device."
		elog ""
		elog "Try enabling the 'xnvctrl' useflag."
		elog ""
	fi

	if use mangoapp; then
		elog ""
		elog "mangoapp is intended to be used with gui-wm/gamescope."
		elog "To use it launch gamescope with the --mangoapp flag:"
		elog ""
		elog "  gamescope --mangoapp -- %command%"
		elog ""
		elog "This is the only supported way to run mangohud in a gamescope session."
		elog ""
	elif has_version gui-wm/gamescope; then
		elog ""
		elog "Enable the 'mangoapp' USE-flag to use mangohud in a gamescope"
		elog "session (via the --mangoapp flag)."
		elog "Using normal mangohud with gamescope is not supported."
		elog ""
	fi
}
