# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils xdg cmake

DESCRIPTION="Jellyfin Desktop Client (Based on plex-media-player)"
HOMEPAGE="http://jellyfin.org/"

# To change on every release bump:
WEB_CLIENT_VERSION="10.7.3"

RESTRICT="mirror"

SRC_URI="
	https://github.com/jellyfin/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/iwalton3/jellyfin-web-jmp/releases/download/jwc-${WEB_CLIENT_VERSION}/dist.zip -> jwc-${WEB_CLIENT_VERSION}.zip
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cec joystick lirc"

QT_VERSION=5.11.2
DEPEND="
	>=dev-qt/qtcore-${QT_VERSION}
	>=dev-qt/qtnetwork-${QT_VERSION}
	>=dev-qt/qtxml-${QT_VERSION}
	>=dev-qt/qtwebchannel-${QT_VERSION}[qml]
	>=dev-qt/qtwebengine-${QT_VERSION}
	>=dev-qt/qtdeclarative-${QT_VERSION}
	>=dev-qt/qtquickcontrols-${QT_VERSION}
	>=dev-qt/qtx11extras-${QT_VERSION}
	>=dev-qt/qtdbus-${QT_VERSION}
	media-video/mpv[libmpv]
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXrandr

	|| (
		media-video/ffmpeg[openssl]
		media-video/ffmpeg[gnutls]
		media-video/ffmpeg[securetransport]
	)

	cec? (
		>=dev-libs/libcec-2.2.0
	)

	joystick? (
		media-libs/libsdl2
		virtual/libiconv
	)
"

RDEPEND="
	${DEPEND}

	lirc? (
		app-misc/lirc
	)
"

PATCHES=(
	"${FILESDIR}/dont_copy_qtwebengine_devtools_resources_pak_file.patch"
)

CMAKE_IN_SOURCE_BUILD=1

src_prepare() {
	sed -i -e '/^  install(FILES ${QTROOT}\/resources\/qtwebengine_devtools_resources.pak DESTINATION resources)$/d' src/CMakeLists.txt || die

	cmake_src_prepare

	eapply_user
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_ENABLE_CEC=$(usex cec)
		-DCMAKE_ENABLE_SDL=$(usex joystick)
		-DCMAKE_ENABLE_LIRC=$(usex lirc)
		-DQTROOT="${EPREFIX}/usr/share/qt5"
	)

	export BUILD_NUMBER="${BUILD}"

	cmake_src_configure

	# Copy webclient into build directory.
	cp -r "${WORKDIR}/dist" "${BUILD_DIR}"
}

src_install() {
	cmake_src_install
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
