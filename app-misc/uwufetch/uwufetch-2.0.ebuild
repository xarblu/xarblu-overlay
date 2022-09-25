# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A meme system info tool for Linux, based on nyan/uwu trend on r/linuxmasterrace"
HOMEPAGE="https://github.com/TheDarkBug/uwufetch"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/TheDarkBug/uwufetch.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/TheDarkBug/uwufetch/archive/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="gpu viu"

DEPEND="
		gpu? ( sys-apps/lshw )
		viu? ( media-gfx/viu )
"
RDEPEND="${DEPEND}"
BDEPEND=""


src_prepare() {
	#Fix paths in Makefile
	sed -i \
		-e "93s/build//" \
		-e "94s/\$(PREFIX)/usr\/&/" \
		-e "94s/\$(LIBDIR)/usr\/$(get_libdir)/" \
		-e "94s/\$(MANDIR)/usr\/&/" \
		-e "94s/\$(ETC_DIR)/\$(DESTDIR)\$(ETC_DIR)/" \
		-e "94s/$/ \$(DESTDIR)\/usr\/include &/" \
		-e "95s/\$(PREFIX)/usr\/&/" \
		-e "96s/\$(LIBDIR)/usr\/$(get_libdir)/" \
		-e "97s/include/usr\/&/" \
		-e "98s/\$(LIBDIR)/usr\/$(get_libdir)/" \
		-e "99s/\$(ETC_DIR)/\$(DESTDIR)\/&/" \
		-e "100s/1.gz/1/" \
		-e "100s/\$(MANDIR)/usr\/&/" \
	${S}/Makefile

	default
}
