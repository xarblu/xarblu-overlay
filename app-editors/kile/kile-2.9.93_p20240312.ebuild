# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ECM_HANDBOOK="forceoptional"
KDE_ORG_CATEGORY="office"
KDE_ORG_COMMIT="078a771ff425149b0240369288f0c323c3f7e671"
KFMIN=6.0.0
QTMIN=6.6.0
MY_P=${P/_beta/b}
inherit ecm kde.org

DESCRIPTION="Latex Editor and TeX shell based on KDE Frameworks"
HOMEPAGE="https://apps.kde.org/kile/"

LICENSE="FDL-1.2 GPL-2"
SLOT="6"
KEYWORDS="~amd64"
IUSE="+pdf +png"

DEPEND="
	>=dev-qt/qtbase-${QTMIN}:${SLOT}[dbus,widgets]
	>=dev-qt/qtdeclarative-${QTMIN}:${SLOT}
	>=dev-qt/qt5compat-${QTMIN}:${SLOT}
	kde-apps/okular:${SLOT}
	>=kde-frameworks/kcodecs-${KFMIN}:${SLOT}
	>=kde-frameworks/kconfig-${KFMIN}:${SLOT}
	>=kde-frameworks/kcoreaddons-${KFMIN}:${SLOT}
	>=kde-frameworks/kcrash-${KFMIN}:${SLOT}
	>=kde-frameworks/kdbusaddons-${KFMIN}:${SLOT}
	>=kde-frameworks/kdoctools-${KFMIN}:${SLOT}
	>=kde-frameworks/kguiaddons-${KFMIN}:${SLOT}
	>=kde-frameworks/ki18n-${KFMIN}:${SLOT}
	>=kde-frameworks/kiconthemes-${KFMIN}:${SLOT}
	>=kde-frameworks/kio-${KFMIN}:${SLOT}
	>=kde-frameworks/kparts-${KFMIN}:${SLOT}
	>=kde-frameworks/ktexteditor-${KFMIN}:${SLOT}
	>=kde-frameworks/kwindowsystem-${KFMIN}:${SLOT}
	>=kde-frameworks/kxmlgui-${KFMIN}:${SLOT}
	>=kde-frameworks/ktextwidgets-${KFMIN}:${SLOT}
	pdf? ( app-text/poppler[qt6] )
"
RDEPEND="${DEPEND}
	kde-apps/konsole:${SLOT}
	kde-apps/okular:${SLOT}[pdf?]
	virtual/latex-base
	virtual/tex-base
	pdf? (
		app-text/ghostscript-gpl
		app-text/texlive-core
	)
	png? (
		app-text/dvipng
		virtual/imagemagick-tools[png?]
	)
"

DOCS=( kile-remote-control.txt )

PATCHES=(
	"${FILESDIR}/${PN}-2.9.93_p20221123-cmake.patch"
	"${FILESDIR}/${PN}-2.9.93_p20240312-clang.patch"
)

src_configure() {
	local mycmakeargs=(
		$(cmake_use_find_package pdf Poppler)
	)
	ecm_src_configure
}
