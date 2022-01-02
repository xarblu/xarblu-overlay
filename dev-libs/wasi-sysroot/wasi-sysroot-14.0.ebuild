# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="WASI-enabled WebAssembly C/C++ toolchain (sysroot)"
HOMEPAGE="https://github.com/WebAssembly/wasi-sdk"
SRC_URI="https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${PV%.*}/wasi-sysroot-${PV}.tar.gz"

LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/wasi-sysroot"

src_install() {
	export GNUTARGET="wasm32"
	insinto "/opt"
	doins -r "${S}"
}
