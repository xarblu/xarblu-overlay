# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="WASI libc implementation for WebAssembly"
HOMEPAGE="https://github.com/WebAssembly/wasi-libc/"

MY_P=${PN}-${PV}-alpha

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_SRC_URI="https://github.com/WebAssembly/wasi-libc.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/WebAssembly/wasi-libc/archive/v${PV}-alpha.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="Apache 2.0"
SLOT="0"

DEPEND="
	>=sys-devel/clang-8.0
	>=sys-devel/llvm-8.0"
RDEPEND="${DEPEND}"

src_unpack() {
	default
	mv "${MY_P}" "${P}"
}

src_compile() {
	emake WASM_CC=clang
}
