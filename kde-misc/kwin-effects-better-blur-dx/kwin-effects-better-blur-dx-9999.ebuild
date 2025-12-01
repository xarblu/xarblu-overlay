# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

KPMIN="6.4.0"
KFMIN="6.0.0"
QTMIN="6.6.0"

inherit multibuild ecm

DESCRIPTION="KWin Blur effect for KDE Plasma 6 to blur any window"
HOMEPAGE="https://github.com/xarblu/kwin-effects-better-blur-dx"

if [[ "${PV}" == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/xarblu/kwin-effects-better-blur-dx.git"
else
	SRC_URI="https://github.com/xarblu/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="6"

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
	>=dev-qt/qtbase-${QTMIN}:6=[dbus,gui,network,opengl,widgets]
	>=dev-qt/qtdeclarative-${QTMIN}:6=
	>=kde-frameworks/kcmutils-${KFMIN}:6=
	>=kde-frameworks/kcolorscheme-${KFMIN}:6=
	>=kde-frameworks/kconfig-${KFMIN}:6=
	>=kde-frameworks/kconfigwidgets-${KFMIN}:6=
	>=kde-frameworks/kcoreaddons-${KFMIN}:6=
	>=kde-frameworks/ki18n-${KFMIN}:6=
	>=kde-frameworks/kwidgetsaddons-${KFMIN}:6=
	>=kde-frameworks/kwindowsystem-${KFMIN}:6=
	>=kde-plasma/kdecoration-${KPMIN}:6
	media-libs/libepoxy
	x11-libs/libX11
	x11-libs/libxcb
	${KWIN_DEP}
"
RDEPEND="${DEPEND}"

kwin_src_configure() {
	local mycmakeargs=()

	# shellcheck disable=SC2153
	case "${MULTIBUILD_VARIANT}" in
		kwin) mycmakeargs+=( -DBETTERBLUR_X11=OFF ) ;;
		kwin-x11) mycmakeargs+=( -DBETTERBLUR_X11=ON ) ;;
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
