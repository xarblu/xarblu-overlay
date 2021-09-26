# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
	ansi_term-0.11.0
	atty-0.2.14
	bitflags-1.2.1
	cfg-if-1.0.0
	clap-2.33.3
	hermit-abi-0.1.18
	instant-0.1.9
	libc-0.2.89
	lock_api-0.4.2
	owo-colors-1.3.0
	parking_lot-0.11.1
	parking_lot_core-0.8.3
	proc-macro2-1.0.24
	quote-1.0.9
	redox_syscall-0.2.5
	scopeguard-1.1.0
	smallvec-1.6.1
	strsim-0.8.0
	syn-1.0.64
	textwrap-0.11.0
	thiserror-1.0.24
	thiserror-impl-1.0.24
	unicode-width-0.1.8
	unicode-xid-0.2.1
	vec_map-0.8.2
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="fastest text uwuifier in the west"
HOMEPAGE="https://github.com/Daniel-Liu-c0deb0t/uwu"
SRC_URI="https://github.com/Daniel-Liu-c0deb0t/uwu/archive/v${PV}.tar.gz -> ${P}.tar.gz
		$(cargo_crate_uris)"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_unpack() {
	#after unpacking rename the src folder
	if [[ -n ${A} ]]; then
		unpack ${A}
	fi
	mv ${WORKDIR}/uwu-${PV} ${WORKDIR}/${P}
	cargo_src_unpack
}

src_prepare() {
	default
	cargo_gen_config
}

src_compile() {
	cargo_src_compile
}

src_install() {
	cargo_src_install
}
