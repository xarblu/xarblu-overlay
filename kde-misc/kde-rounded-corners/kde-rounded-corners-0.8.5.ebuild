# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

KFMIN="6.10.0"
ECM_NONGUI="true"

inherit ecm multibuild

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

# the only test is a post-install check
# asking kwin if the effect is loaded
RESTRICT="test"

kwin_src_configure() {
	local mycmakeargs=()

	# shellcheck disable=SC2153
	case "${MULTIBUILD_VARIANT}" in
		kwin) mycmakeargs+=( -DKWIN_X11=OFF ) ;;
		kwin-x11) mycmakeargs+=( -DKWIN_X11=ON ) ;;
		*) die "Unknown version" ;;
	esac

	ecm_src_configure
}

pkg_setup() {
	# shellcheck disable=SC2207 # we don't want these quoted to avoid empty ""
	MULTIBUILD_VARIANTS=(
		$(usev wayland kwin)
		$(usev X kwin-x11)
	)
}

src_prepare() {
	# we need to avoid applying patches twice
	# eapply_user should fine because it has
	# ${T}/.portage_user_patches_applied
	eapply -- "${PATCHES[@]}"
	unset PATCHES

	multibuild_foreach_variant ecm_src_prepare
}

src_configure() {
	multibuild_foreach_variant kwin_src_configure
}

src_compile() {
	multibuild_foreach_variant ecm_src_compile
}

src_install() {
	multibuild_foreach_variant ecm_src_install
}
