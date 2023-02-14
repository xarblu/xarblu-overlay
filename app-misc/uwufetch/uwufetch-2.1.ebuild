# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

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
	sed -i \
		-e "s/^UWUFETCH_VERSION =.*/UWUFETCH_VERSION = $(uwufetch_v)/" \
		-e "s/install: build/install:/" \
		-e "s/-shared/-shared -Wl,-soname,lib\$(LIB_FILES:.c=.so)/" \
		-e "s/\$(ETC_DIR)\/\$(NAME)$/\$(ETC_DIR)\/\$(NAME) \$(DESTDIR)\/include/" \
		${S}/Makefile || die "sed failed"

	default
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		CFLAGS="${CFLAGS} -DUWUFETCH_VERSION=\"$(uwufetch_v)\"" \
		build
}

src_install() {
	emake \
		DESTDIR="${ED}"/usr \
		ETC_DIR="${ED}"/etc \
		LIBDIR="$(get_libdir)" \
		install
}
