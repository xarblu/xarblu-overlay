# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

KFMIN="6.10.0"
ECM_NONGUI="true"

inherit ecm

MY_PN="KDE-Rounded-Corners"

DESCRIPTION="Rounds the corners of your windows in KDE Plasma 6"
HOMEPAGE="https://github.com/matinlotfali/KDE-Rounded-Corners"
SRC_URI="https://github.com/matinlotfali/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-3"
SLOT="6"
KEYWORDS="~amd64"
IUSE="wayland X"

REQUIRED_USE="|| ( wayland X )"

KWIN_DEP="
	wayland? (
		kde-plasma/kwin:${SLOT}
	)
	X? (
		kde-plasma/kwin-x11:${SLOT}
	)
"

DEPEND="
	>=kde-frameworks/kcmutils-${KFMIN}:${SLOT}=
	>=kde-frameworks/kconfigwidgets-${KFMIN}:${SLOT}=
	>=kde-frameworks/ki18n-${KFMIN}:${SLOT}=
	media-libs/libepoxy
	x11-libs/libxcb
	${KWIN_DEP}
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/qt-6.10.patch" )

foreach_kwin_version() {
	local version
	for version in "${KWIN_VERSIONS[@]}"; do
		einfo "${version}: ${*}"

		BUILD_DIR="${CMAKE_USE_DIR}_build.${version}"

		local mycmakeargs=()
		case "${version}" in
			kwin) mycmakeargs+=( -DKWIN_X11=OFF ) ;;
			kwin-x11) mycmakeargs+=( -DKWIN_X11=ON ) ;;
			*) die "Unknown version" ;;
		esac

		"${@}"
	done
}

pkg_setup() {
	declare -ga KWIN_VERSIONS=()

	# shellcheck disable=SC2207 # we don't want these quoted to avoid empty ""
	KWIN_VERSIONS+=(
		$(usev wayland kwin)
		$(usev X kwin-x11)
	)
}

src_prepare() {
	foreach_kwin_version ecm_src_prepare
}

src_configure() {
	foreach_kwin_version ecm_src_configure
}

src_compile() {
	foreach_kwin_version ecm_src_compile
}

src_install() {
	foreach_kwin_version ecm_src_install
}
