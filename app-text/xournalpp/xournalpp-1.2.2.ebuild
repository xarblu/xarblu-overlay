# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-3 lua5-4 )
inherit cmake lua-single xdg

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/xournalpp/xournalpp.git"
else
	SRC_URI="https://github.com/xournalpp/xournalpp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tgz"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Handwriting notetaking software with PDF annotation support"
HOMEPAGE="https://github.com/xournalpp/xournalpp"

LICENSE="GPL-2"
SLOT="0"

IUSE="tex +X"

REQUIRED_USE="${LUA_REQUIRED_USE}"

COMMON_DEPEND="
	${LUA_DEPS}
	app-text/poppler[cairo]
	dev-libs/glib
	dev-libs/libxml2
	dev-libs/libzip:=
	gnome-base/librsvg
	media-libs/portaudio[cxx]
	media-libs/libsndfile
	sys-libs/zlib:=
	tex? ( x11-libs/gtksourceview:4 )
	x11-libs/gtk+:3
	X? (
		x11-libs/libXext
		x11-libs/libXi
	)
"
RDEPEND="
	${COMMON_DEPEND}
	tex? ( app-text/texlive[graphics] )
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	virtual/pkgconfig
	sys-apps/lsb-release
	sys-devel/gettext
"

PATCHES=(
	"${FILESDIR}/${PN}-1.1.1-nostrip.patch"
	"${FILESDIR}/${PN}-1.2.2-nocompress.patch"
	"${FILESDIR}/${PN}-1.2.2-lua-single.patch"
)

src_configure() {
	local mycmakeargs=(
		-DLUA_VERSION="$(lua_get_version)"
		-DCMAKE_$(usex X "REQUIRED_FIND_PACKAGE_X11" "DISABLE_FIND_PACKAGE_X11")=ON
	)

	cmake_src_configure
}
