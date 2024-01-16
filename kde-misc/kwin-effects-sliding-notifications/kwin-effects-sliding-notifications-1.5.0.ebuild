# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Sliding animation for notification windows"
HOMEPAGE="https://github.com/zzag/kwin-effects-sliding-notifications"

KWINEFFECTS_V="5.27*"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zzag/${PN}.git"
	KEYWORDS=""
	KWIN="kde-plasma/kwin"
else
	SRC_URI="https://github.com/zzag/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	KWIN="=kde-plasma/kwin-${KWINEFFECTS_V}:5="
fi

LICENSE="GPL-3 MIT"
SLOT="0"

DEPEND="
	${KWIN}
	dev-qt/qtcore:5=
	dev-qt/qtgui:5=
	kde-plasma/kwin:5=
	kde-frameworks/kconfig:5=
	kde-frameworks/kconfigwidgets:5=
	kde-frameworks/kcoreaddons:5=
	kde-frameworks/kwindowsystem:5=
	x11-libs/libxcb
	media-libs/libepoxy
"
RDEPEND="${DEPEND}"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0=
"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_PREFIX=/usr
	)
	cmake_src_configure
}
