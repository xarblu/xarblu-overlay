# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )

inherit toolchain-funcs flag-o-matic python-r1 desktop meson-multilib

DESCRIPTION="Vulkan and OpenGL overlay for monitoring FPS, sensors, system load and more"
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

MY_PV=$(ver_cut 1-3)
[[ -n "$(ver_cut 4-)" ]] && MY_PV_REV="-$(ver_cut 4-)"

# required subprojects
declare -A subprojectv=(
	[vkheaders]="1.2.158"
	[vkheaders_meson]="1.2.158-2"
	[imgui]="1.89.9"
	[imgui_meson]="1.89.9-1"
	[implot]="0.16"
	[implot_meson]="0.16-1"
)

SRC_URI="
	https://github.com/flightlessmango/MangoHud/archive/v${MY_PV}${MY_PV_REV}.tar.gz -> ${P}.tar.gz
	https://github.com/KhronosGroup/Vulkan-Headers/archive/v${subprojectv[vkheaders]}.tar.gz -> vulkan-headers-${subprojectv[vkheaders]}.tar.gz
	https://wrapdb.mesonbuild.com/v2/vulkan-headers_${subprojectv[vkheaders_meson]}/get_patch/vulkan-headers-${subprojectv[vkheaders_meson]}-wrap.zip
	https://github.com/ocornut/imgui/archive/v${subprojectv[imgui]}.tar.gz -> imgui-${subprojectv[imgui]}.tar.gz
	https://wrapdb.mesonbuild.com/v2/imgui_${subprojectv[imgui_meson]}/get_patch/imgui-${subprojectv[imgui_meson]}-wrap.zip
	https://github.com/epezent/implot/archive/v${subprojectv[implot]}.tar.gz -> imgui-${subprojectv[implot]}.tar.gz
	https://wrapdb.mesonbuild.com/v2/implot_${subprojectv[implot_meson]}/get_patch/implot-${subprojectv[implot_meson]}-wrap.zip
"

KEYWORDS="~amd64"
LICENSE="MIT"
SLOT="0"
IUSE="+dbus debug mangoapp mangoplot test wayland video_cards_nvidia +X xnvctrl"

REQUIRED_USE="
	|| ( X wayland )
	mangoapp? ( X )
	xnvctrl? ( video_cards_nvidia X )
	${PYTHON_REQUIRED_USE}
"

RESTRICT="!test? ( test )"

BDEPEND="
	app-arch/unzip
	test? ( dev-util/cmocka[${MULTILIB_USEDEP}] )
	$(python_gen_cond_dep 'dev-python/mako[${PYTHON_USEDEP}]')
	${PYTHON_DEPS}
"

DEPEND="
	dev-cpp/nlohmann_json
	dev-libs/spdlog[${MULTILIB_USEDEP}]
	dev-util/glslang[${MULTILIB_USEDEP}]
	media-libs/libglvnd[${MULTILIB_USEDEP}]
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	x11-libs/libdrm[${MULTILIB_USEDEP}]
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	mangoapp? (
		media-libs/glew[${MULTILIB_USEDEP}]
		media-libs/glfw[-wayland-only(-),X(+),${MULTILIB_USEDEP}]
	)
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[${MULTILIB_USEDEP}]
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? (
		>=dev-libs/wayland-1.11[${MULTILIB_USEDEP}]
		x11-libs/libxkbcommon[${MULTILIB_USEDEP}]
	)
	X? (
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libxkbcommon[${MULTILIB_USEDEP}]
	)
	${PYTHON_DEPS}
"

RDEPEND="
	mangoplot? (
		$(python_gen_cond_dep '
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/matplotlib[${PYTHON_USEDEP}]
		')
	)
	${DEPEND}
"

S="${WORKDIR}/MangoHud-${PV}"

python_check_deps() {
	python_has_version -b "dev-python/mako[${PYTHON_USEDEP}]"
}

pkg_setup() {
	python_setup
}

src_unpack() {
	default
	[[ -n "${MY_PV_REV}" ]] && ( mv "${WORKDIR}/MangoHud-${MY_PV}${MY_PV_REV}" "${WORKDIR}/MangoHud-${PV}" || die )

	# symlink subprojects
	local projects=( Vulkan-Headers-${subprojectv[vkheaders]}
					 imgui-${subprojectv[imgui]}
					 implot-${subprojectv[implot]}
					)

	for subproject in "${projects[@]}"; do
		einfo "Symlinking subproject ${subproject}"
		ln -sfv "${WORKDIR}/${subproject}" "${S}/subprojects/" || die "Couldn't symlink ${subproject}"
	done
}

src_prepare() {
	# set version since we don't have git tags
	sed -i -e "/^project('MangoHud',$/,/^)$/s/version : '.*'/version : '${MY_PV}${MY_PV_REV}'/" \
		meson.build || die

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
		$(meson_use mangoapp mangoapp)
		# mangohudctl only makes sense with mangoapp
		$(meson_use mangoapp mangohudctl)
		$(meson_feature test tests)
		$(meson_feature mangoplot mangoplot)
		-Ddynamic_string_tokens=true
		# no extra deps and just a single object so whatever
		-Dwith_fex=true
	)
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
}
