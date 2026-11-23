# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit toolchain-funcs flag-o-matic python-r1 meson-multilib

DESCRIPTION="Vulkan and OpenGL overlay for monitoring FPS, sensors, system load and more"
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

MY_PV=$(ver_cut 1-3)
[[ -n "$(ver_cut 4-)" ]] && MY_PV_REV="-$(ver_cut 4-)"

# format:
# <name>;<use>;<src_uri>;<dest>;<rev>
# src_uri and dest may have a @@rev@@ placeholder
SUBPROJECTS=(
	'imgui;-;https://github.com/ocornut/imgui/archive/v@@rev@@.tar.gz;imgui-@@rev@@;1.91.6'
	'implot;-;https://github.com/epezent/implot/archive/refs/tags/v@@rev@@.tar.gz;implot-@@rev@@;0.16'
	'implot_meson;-;https://github.com/mesonbuild/wrapdb/releases/download/implot_@@rev@@/implot_@@rev@@_patch.zip;implot-@@rev@@;0.16-1'
	'vulkan-headers;-;https://github.com/KhronosGroup/Vulkan-Headers/archive/v@@rev@@.tar.gz;Vulkan-Headers-@@rev@@;1.4.346'
	'vulkan-utility-libraries;-;https://github.com/KhronosGroup/Vulkan-Utility-Libraries/archive/v@@rev@@.tar.gz;Vulkan-Utility-Libraries-@@rev@@;1.4.346'

	# mangohud-next
	'vk-bootstrap;mangohud-next;https://github.com/charles-lunarg/vk-bootstrap/archive/v@@rev@@.tar.gz;vk-bootstrap;1.4.328'
	'vkroots;mangohud-next;https://github.com/misyltoad/vkroots/archive/@@rev@@.tar.gz;vkroots;5106d8a0df95de66cc58dc1ea37e69c99afc9540'
	'wlr-protocols;mangohud-next;https://gitlab.freedesktop.org/wlroots/wlr-protocols/-/archive/@@rev@@/wlr-protocols-@@rev@@.tar.bz2;wlr-protocols-@@rev@@;bf4fc79abc359eea5a0edec0ac6d4a2b2955f82a'
)

SRC_URI="
	https://github.com/flightlessmango/MangoHud/archive/v${MY_PV}${MY_PV_REV}.tar.gz
		-> ${P}.tar.gz
"

setup_globals() {
	local name use src_uri dest rev
	local ext

	while IFS=';' read -r name use src_uri dest rev; do
		src_uri="${src_uri//"@@rev@@"/"${rev}"}"
		case "${src_uri}" in
			*.tar.bz2) ext="tar.bz2" ;;
			*.tar.gz) ext="tar.gz" ;;
			*.zip) ext="zip" ;;
			*) die "Could not parse extension from ${src_uri@Q}"
		esac

		[[ "${use}" == '-' ]] || SRC_URI+=" ${use}? ("

		SRC_URI+=" ${src_uri} -> ${name}-${rev}.${ext} "

		[[ "${use}" == '-' ]] || SRC_URI+=") "
	done < <(printf '%s\n' "${SUBPROJECTS[@]}")
}
setup_globals
unset -f setup_globals

S="${WORKDIR}/MangoHud-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+dbus debug mangoapp mangohud-next mangoplot test systemd wayland video_cards_nvidia +X xnvctrl"

REQUIRED_USE="
	|| ( X wayland )
	mangoapp? ( X )
	xnvctrl? ( video_cards_nvidia X )
	${PYTHON_REQUIRED_USE}
"

# elogind has no multilib (yet) so
# mangohud-next will only work on native abi...
REQUIRED_USE+=" mangohud-next? ( !systemd? ( !abi_x86_32 ) )"

# TODO: remove once dev-python/matplotlib
# has py3.15 support
REQUIRED_USE+=" mangoplot? ( !python_targets_python3_15 )"

RESTRICT="!test? ( test )"

# shellcheck disable=SC2016
BDEPEND="
	app-arch/unzip
	test? (
		dev-libs/appstream
		dev-util/cmocka[${MULTILIB_USEDEP}]
	)
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
		x11-libs/libXi
	)
	mangohud-next? (
		dev-cpp/yaml-cpp[${MULTILIB_USEDEP}]
		dev-libs/libtracefs
		systemd? ( sys-apps/systemd[${MULTILIB_USEDEP}] )
		!systemd? ( sys-auth/elogind )
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

PATCHES=(
	"${FILESDIR}/${PV}-0001-classic-fix-libcxx-atomic-shared_ptr.patch"
	"${FILESDIR}/${PV}-0002-classic-fix-libcxx-atomic-shared_ptr.patch"
)

python_check_deps() {
	python_has_version -b "dev-python/mako[${PYTHON_USEDEP}]"
}

pkg_setup() {
	if [[ "${MERGE_TYPE}" != binary && "$(tc-get-cxx-stdlib)" == libc++ ]]; then
		if use mangohud-next; then
			eerror "mangohud-next uses std::atomic<shared_ptr<T>> which libc++ does not support yet."
			eerror "See https://github.com/flightlessmango/MangoHud/issues/2231"
			die "mangohud-next broken on libc++"
		fi
	fi

	python_setup
}

src_unpack() {
	default
	[[ -n "${MY_PV_REV}" ]] && ( mv "${WORKDIR}/MangoHud-${MY_PV}${MY_PV_REV}" "${WORKDIR}/MangoHud-${PV}" || die )
}

src_prepare() {
	local name use src_uri dest rev
	local ext file packagefiles
	local shopt
	local -a src

	shopt="$(shopt -p nullglob)"
	shopt -s nullglob

	# setup subprojects
	while IFS=';' read -r name use src_uri dest rev; do
		# meson patch zips extract on top of their base in WORKDIR
		[[ "${name}" == *_meson ]] && continue

		# skip use dependent subprojects
		[[ "${use}" != '-' ]] && use "!${use}" && continue

		dest="${dest//"@@rev@@"/"${rev}"}"
		src=( "${WORKDIR}/${dest}"* )

		# main subproject
		mv -v "${src[0]}" "subprojects/${dest}" || die

		# packagefiles
		if [[ -d "subprojects/packagefiles/${name}" ]]; then
			packagefiles="subprojects/packagefiles/${name}"
		elif [[ -d "subprojects/packagefiles/${name}-${rev}" ]]; then
			packagefiles="subprojects/packagefiles/${name}-${rev}"
		else
			continue
		fi

		for file in "${packagefiles}"/*; do
			mv -vt "subprojects/${dest}" "${file}" || die
		done
	done < <(printf '%s\n' "${SUBPROJECTS[@]}")

	${shopt}

	# set version since we don't have git tags
	sed -i -e "/^project('MangoHud',$/,/^)$/s/version : '.*'/version : '${MY_PV}${MY_PV_REV}'/" \
		meson.build || die

	# we expect system spdlog so disallow the fallback to bundled
	sed -i -e '/^spdlog_dep/s/required: false/required: true/' meson.build || die

	# don't statically link GCC libstdc++
	# this is likely done to avoid ABI issues with the Steam runtime
	# (which I could not find) but breaks the build on LLVM libc++ systems entirely
	sed -i -e "/^link_args =/s/, '-static-libstdc++'//" src/meson.build || die
	sed -i -e "/^ *'-static-libstdc++',$/d" mangohud-next/client/meson.build || die

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
		$(meson_feature video_cards_nvidia with_nvml)
		$(meson_feature xnvctrl with_xnvctrl)
		$(meson_feature X with_x11)
		$(meson_feature wayland with_wayland)
		$(meson_feature dbus with_dbus)
		$(meson_feature test tests)
		# no extra deps but afaik only relevant on arm64
		$(meson_use arm64 with_fex)

		# mangohud-next
		$(meson_use mangohud-next with_mangohud_next)
	)

	# the tools are meant for the native ABI only
	# and this avoids a ton of useless 32bit libs
	if multilib_is_native_abi; then
		emesonargs+=(
			-Dinclude_doc=true
			$(meson_use mangoapp mangoapp)
			# mangohudctl only makes sense with mangoapp
			$(meson_use mangoapp mangohudctl)
			$(meson_feature mangoplot mangoplot)

			# mangohud-next
			$(meson_use mangohud-next with_server)
		)
	else
		# same options as above but explicitly
		# disabled for non-native arch
		emesonargs+=(
			-Dinclude_doc=false
			-Dmangoapp=false
			-Dmangohudctl=false
			-Dmangoplot=disabled
			-Dwith_server=false
		)
	fi

	meson_src_configure
}

multilib_src_install_all() {
	# Gentoo FHS
	dodoc "${ED}"/usr/share/doc/mangohud/* || die
	rm -r "${ED}"/usr/share/doc/mangohud || die
	einstalldocs
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
