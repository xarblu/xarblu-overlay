# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	addr2line@0.15.2
	adler2@2.0.0
	adler@1.0.2
	android-tzdata@0.1.1
	android_system_properties@0.1.5
	autocfg@1.4.0
	backtrace@0.3.59
	bitflags@2.9.1
	bumpalo@3.18.1
	bytes@1.10.1
	cc@1.2.25
	cfg-if@1.0.0
	cfg_aliases@0.2.1
	chrono@0.4.41
	core-foundation-sys@0.8.7
	crc32fast@1.4.2
	darwin-libproc-sys@0.2.0
	darwin-libproc@0.2.0
	derive_more-impl@1.0.0
	derive_more@1.0.0
	discord-rich-presence@0.2.5
	errno@0.3.12
	flate2@1.1.1
	futures-channel@0.3.31
	futures-core@0.3.31
	futures-executor@0.3.31
	futures-io@0.3.31
	futures-macro@0.3.31
	futures-sink@0.3.31
	futures-task@0.3.31
	futures-util@0.3.31
	futures@0.3.31
	getrandom@0.2.16
	gimli@0.24.0
	glob@0.3.2
	hermit-abi@0.5.1
	hex@0.4.3
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.63
	itoa@1.0.15
	js-sys@0.3.77
	libc@0.2.172
	linux-raw-sys@0.4.15
	lock_api@0.4.13
	log@0.4.27
	mach2@0.4.2
	memchr@2.3.4
	miniz_oxide@0.4.4
	miniz_oxide@0.8.8
	mio@1.0.4
	nix@0.29.0
	num-traits@0.2.19
	num_cpus@1.17.0
	object@0.24.0
	once_cell@1.21.3
	parking_lot@0.12.4
	parking_lot_core@0.9.11
	pin-project-lite@0.2.16
	pin-utils@0.1.0
	platforms@3.6.0
	proc-macro2@1.0.95
	procfs-core@0.17.0
	procfs@0.17.0
	psutil@5.2.0
	quote@1.0.40
	redox_syscall@0.5.12
	rustc-demangle@0.1.24
	rustix@0.38.44
	rustversion@1.0.21
	ryu@1.0.20
	scopeguard@1.2.0
	serde@1.0.219
	serde_derive@1.0.219
	serde_json@1.0.140
	serde_repr@0.1.20
	shlex@1.3.0
	signal-hook-registry@1.4.5
	slab@0.4.9
	smallvec@1.15.0
	socket2@0.5.10
	syn@2.0.101
	thiserror-impl@2.0.12
	thiserror@2.0.12
	tokio-macros@2.5.0
	tokio@1.45.1
	unescape@0.1.0
	unicode-ident@1.0.18
	uuid@0.8.2
	wasi@0.11.0+wasi-snapshot-preview1
	wasm-bindgen-backend@0.2.100
	wasm-bindgen-macro-support@0.2.100
	wasm-bindgen-macro@0.2.100
	wasm-bindgen-shared@0.2.100
	wasm-bindgen@0.2.100
	windows-core@0.61.2
	windows-implement@0.60.0
	windows-interface@0.59.1
	windows-link@0.1.1
	windows-result@0.3.4
	windows-strings@0.4.2
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
"

RUST_MIN_VER="1.85.0"

inherit cargo systemd

DESCRIPTION="Discord Rich Presence for Portage"
HOMEPAGE="https://github.com/xarblu/portpresence"
SRC_URI="
	https://github.com/xarblu/portpresence/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	MIT Unicode-3.0
	|| ( Apache-2.0 Boost-1.0 )
"
SLOT="0"
KEYWORDS="~amd64"

src_install() {
	cargo_src_install
	systemd_douserunit "meta/${PN}.service"
}
