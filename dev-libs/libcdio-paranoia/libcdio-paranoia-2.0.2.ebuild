# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV=release-10.2+${PV/_p/+}
MY_P=${PN}-${MY_PV}

inherit autotools multilib-minimal

DESCRIPTION="an advanced CDDA reader with error correction"
HOMEPAGE="https://www.gnu.org/software/libcdio/"
SRC_URI="https://github.com/rocky/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

# COPYING-GPL from cdparanoia says "2 or later"
# COPYING-LGPL from cdparanoia says "2.1 or later" but 2 files are without the
# clause "or later" so we use LGPL-2.1 without +
LICENSE="GPL-3+ GPL-2+ LGPL-2.1"
SLOT="0/2" # soname version
KEYWORDS="~amd64"
IUSE="+cxx static-libs test"

RDEPEND="app-eselect/eselect-cdparanoia
	>=dev-libs/libcdio-2.0.0:0=[${MULTILIB_USEDEP}]
	>=virtual/libiconv-0-r1[${MULTILIB_USEDEP}]
"

DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
	test? ( dev-lang/perl )"

RESTRICT="!test? ( test )"

S="${WORKDIR}/${MY_P//+/-}"

DOCS=( AUTHORS NEWS.md README.md THANKS )

src_prepare() {
	default
	#sed -i -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' configure.ac || die #466410
	eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		#--disable-maintainer-mode
		--disable-example-progs
		$(use_enable cxx)
		--disable-cpp-progs
		--with-cd-paranoia-name=libcdio-paranoia
		$(use_enable static-libs static)
	)
	# Darwin linker doesn't get this
	[[ ${CHOST} == *-darwin* ]] && myeconfargs+=( --disable-ld-version-script )

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die
}

pkg_postinst() {
	eselect cdparanoia update ifunset
}

pkg_postrm() {
	eselect cdparanoia update ifunset
}
