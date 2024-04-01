# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# combined crate deps of all rust subprojects
# find Cargo.toml -> cargo update -> pycargoebuild
# combine CRATES -> sort -u
CRATES="
	aho-corasick@1.1.3
	anstream@0.6.13
	anstyle@1.0.6
	anstyle-parse@0.2.3
	anstyle-query@1.0.2
	anstyle-wincon@3.0.2
	anyhow@1.0.81
	autocfg@1.2.0
	bindgen@0.69.4
	bitflags@1.3.2
	bitflags@2.5.0
	bitvec@1.0.1
	buddy-alloc@0.5.1
	camino@1.1.6
	cargo_metadata@0.15.4
	cargo-platform@0.1.8
	cc@1.0.90
	cexpr@0.6.0
	cfg_aliases@0.1.1
	cfg-if@1.0.0
	clang-sys@1.7.0
	clap@4.5.4
	clap_builder@4.5.2
	clap_derive@4.5.4
	clap_lex@0.7.0
	colorchoice@1.0.0
	const_format@0.2.32
	const_format_proc_macros@0.2.32
	convert_case@0.6.0
	ctrlc@3.4.4
	deranged@0.3.11
	dtoa@1.0.9
	either@1.10.0
	equivalent@1.0.1
	errno@0.3.8
	fastrand@2.0.2
	fb_procfs@0.7.1
	filetime@0.2.23
	funty@2.0.0
	glob@0.3.1
	hashbrown@0.14.3
	heck@0.4.1
	heck@0.5.0
	hermit-abi@0.3.9
	hex@0.4.3
	home@0.5.9
	indexmap@2.2.6
	itertools@0.12.1
	itoa@1.0.11
	lazycell@1.3.0
	lazy_static@1.4.0
	libbpf-cargo@0.22.1
	libbpf-rs@0.22.1
	libbpf-sys@1.3.0+v1.3.0
	libc@0.2.153
	libloading@0.8.3
	linux-raw-sys@0.4.13
	lock_api@0.4.11
	log@0.4.21
	memchr@2.7.2
	memmap2@0.5.10
	memoffset@0.6.5
	memoffset@0.9.1
	minimal-lexical@0.2.1
	nix@0.25.1
	nix@0.27.1
	nix@0.28.0
	nom@7.1.3
	num-conv@0.1.0
	num_cpus@1.16.0
	num_enum@0.5.11
	num_enum_derive@0.5.11
	num_threads@0.1.7
	num-traits@0.2.18
	once_cell@1.19.0
	openat@0.1.21
	ordered-float@3.9.2
	parking_lot@0.12.1
	parking_lot_core@0.9.9
	pin-utils@0.1.0
	pkg-config@0.3.30
	powerfmt@0.2.0
	prettyplease@0.2.17
	proc-macro2@1.0.79
	proc-macro-crate@1.3.1
	prometheus-client@0.19.0
	prometheus-client-derive-encode@0.4.2
	quote@1.0.35
	radium@0.7.0
	redox_syscall@0.4.1
	regex@1.10.4
	regex-automata@0.4.6
	regex-syntax@0.6.29
	regex-syntax@0.8.3
	rustc-hash@1.1.0
	rustix@0.38.32
	rustversion@1.0.14
	ryu@1.0.17
	same-file@1.0.6
	scopeguard@1.2.0
	scroll@0.11.0
	scroll_derive@0.11.1
	semver@1.0.22
	serde@1.0.197
	serde_derive@1.0.197
	serde_json@1.0.115
	shlex@1.3.0
	simplelog@0.12.2
	smallvec@1.13.2
	sscanf@0.4.1
	sscanf_macro@0.4.1
	static_assertions@1.1.0
	strsim@0.10.0
	strsim@0.11.0
	strum_macros@0.24.3
	syn@1.0.109
	syn@2.0.57
	tap@1.0.1
	tar@0.4.40
	tempfile@3.10.1
	termcolor@1.4.1
	terminal_size@0.3.0
	thiserror@1.0.58
	thiserror-impl@1.0.58
	threadpool@1.8.1
	time@0.3.34
	time-core@0.1.2
	time-macros@0.2.17
	toml_datetime@0.6.5
	toml_edit@0.19.15
	unicase@2.7.0
	unicode-ident@1.0.12
	unicode-segmentation@1.11.0
	unicode-width@0.1.11
	unicode-xid@0.2.4
	utf8parse@0.2.1
	version_check@0.9.4
	version-compare@0.1.1
	vsprintf@2.0.0
	walkdir@2.5.0
	which@4.4.2
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.6
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.4
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.4
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.4
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.4
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-targets@0.48.5
	windows-targets@0.52.4
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.4
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.4
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.4
	winnow@0.5.40
	wyz@0.5.1
	xattr@1.3.1
"

LLVM_COMPAT=( 17 )

inherit linux-info llvm-r1 cargo meson

DESCRIPTION="sched_ext schedulers and tools"
HOMEPAGE="https://github.com/sched-ext/scx"
SRC_URI="
	https://github.com/sched-ext/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

BDEPEND="
	sys-kernel/linux-headers
	virtual/pkgconfig
	$(llvm_gen_dep '
		sys-devel/clang:${LLVM_SLOT}
		virtual/rust:0/llvm-${LLVM_SLOT}
	')
"
DEPEND="
	>=dev-libs/libbpf-1.3.0
	dev-util/bpftool
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/0.1.7-clang-libcxx.patch" )

CONFIG_CHECK="~SCHED_CLASS_EXT"
WARNING_SCHED_CLASS_EXT="
Make sure your kernel includes the sched-ext
patchset and supports SCHED_CLASS_EXT!

Kernels including this are:
	sys-kernel/cachyos-kernel (USE cachyos or sched-ext)
"

pkg_setup() {
	linux-info_pkg_setup
	llvm-r1_pkg_setup
}

src_configure() {
	local emesonargs=(
		$(meson_feature systemd)
	)
	meson_src_configure
}
