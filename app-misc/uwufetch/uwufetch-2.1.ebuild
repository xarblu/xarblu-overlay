# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A meme system info tool for Linux, based on nyan/uwu trend on r/linuxmasterrace"
HOMEPAGE="https://github.com/TheDarkBug/uwufetch"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/TheDarkBug/uwufetch.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/TheDarkBug/uwufetch/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
fi

LICENSE="GPL-3"
SLOT="0"

IUSE="gpu images X"

DEPEND="
		gpu? ( sys-apps/lshw )
		images? ( media-gfx/viu )
		X? ( x11-apps/xwininfo )
"
RDEPEND="${DEPEND}"
BDEPEND=""

uwufetch_v() {
	if [[ ${PV} == 9999 ]]; then
		local tag="$(git describe --tags)"
		echo "${tag%%-*}"
	else
		echo "${PV}"
	fi
}

src_prepare() {
	#Fix Makefile
	sed -E -i \
		-e 's/^AR = ar/AR ?= ar/' \
		-e 's/^CC = cc/CC ?= cc/' \
		-e 's/^CFLAGS = (.*)/CFLAGS := $(CFLAGS) \1/' \
		-e "s/^(UWUFETCH_VERSION = ).*/\1$(uwufetch_v)/" \
		-e "s/([ \t]*LIBDIR[ \t]*=) lib/\1\/$(get_libdir)/" \
		-e 's/(\$\(CC\) \$\(CFLAGS\) -shared) (-o lib\$\(LIB_FILES:.c=.so\) \$\(LIB_FILES:.c=.o\))/\1 -Wl,-soname,lib\$(LIB_FILES:.c=.so).$(UWUFETCH_VERSION) \2/' \
		-e 's/(.* \$\(ETC_DIR\)\/\$\(NAME\))$/\1 $(DESTDIR)\/include $(DESTDIR)\/lib\/$(NAME)/' \
		-e 's/(cp -r res\/\* \$\(DESTDIR\)\/)\$\(LIBDIR\)(\/\$\(NAME\))/\1lib\2/' \
		-e '/cp \.\/\$\(NAME\)\.1\.gz \$\(DESTDIR\)\/\$\(MANDIR\)/d' \
		-e 's/| gzip //' \
		${S}/Makefile || die "sed failed"

	default
}

src_compile() {
	emake build
}

src_install() {
	emake \
		DESTDIR="${ED}"/usr \
		ETC_DIR="${ED}"/etc \
		install

	doman uwufetch.1
	dosym "libfetch.so" "/usr/$(get_libdir)/libfetch.so.$(uwufetch_v)"
}
