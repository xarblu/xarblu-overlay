# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# combined crate deps of all rust subprojects
# git clean -f; for i in `fd Cargo.toml`; do pushd "${i%/*}"; cargo update; popd; pycargoebuild "${i%/*}"; done; cat *.ebuild | perl -n0e 'print "$1" while /CRATES="\n(.*?)"/gms' | sort -u | tee scx-crate-deps
CRATES="
	aho-corasick@1.1.3
	anstream@0.6.14
	anstyle@1.0.7
	anstyle-parse@0.2.4
	anstyle-query@1.1.0
	anstyle-wincon@3.0.3
	anyhow@1.0.86
	autocfg@1.3.0
	bindgen@0.69.4
	bitflags@1.3.2
	bitflags@2.5.0
	bitvec@1.0.1
	buddy-alloc@0.5.1
	camino@1.1.7
	cargo_metadata@0.15.4
	cargo-platform@0.1.8
	cc@1.0.98
	cexpr@0.6.0
	cfg_aliases@0.1.1
	cfg-if@1.0.0
	clang-sys@1.8.1
	clap@4.5.4
	clap_builder@4.5.2
	clap_derive@4.5.4
	clap_lex@0.7.0
	colorchoice@1.0.1
	const_format@0.2.32
	const_format_proc_macros@0.2.32
	convert_case@0.6.0
	ctrlc@3.4.4
	deranged@0.3.11
	dtoa@1.0.9
	either@1.12.0
	equivalent@1.0.1
	errno@0.3.9
	fastrand@2.1.0
	fb_procfs@0.7.1
	filetime@0.2.23
	funty@2.0.0
	glob@0.3.1
	hashbrown@0.14.5
	heck@0.4.1
	heck@0.5.0
	hermit-abi@0.3.9
	hex@0.4.3
	home@0.5.9
	indexmap@2.2.6
	is_terminal_polyfill@1.70.0
	itertools@0.12.1
	itoa@1.0.11
	lazycell@1.3.0
	lazy_static@1.4.0
	libbpf-cargo@0.23.2
	libbpf-rs@0.23.2
	libbpf-sys@1.4.2+v1.4.2
	libc@0.2.155
	libloading@0.8.3
	linux-raw-sys@0.4.14
	lock_api@0.4.12
	log@0.4.21
	memchr@2.7.2
	memmap2@0.5.10
	memoffset@0.6.5
	minimal-lexical@0.2.1
	nix@0.25.1
	nix@0.28.0
	nom@7.1.3
	num-conv@0.1.0
	num_cpus@1.16.0
	num_enum@0.5.11
	num_enum_derive@0.5.11
	num_threads@0.1.7
	num-traits@0.2.19
	once_cell@1.19.0
	openat@0.1.21
	ordered-float@3.9.2
	parking_lot@0.12.3
	parking_lot_core@0.9.10
	paste@1.0.15
	pin-utils@0.1.0
	pkg-config@0.3.30
	plain@0.2.3
	powerfmt@0.2.0
	prettyplease@0.2.20
	proc-macro2@1.0.85
	proc-macro-crate@1.3.1
	prometheus-client@0.19.0
	prometheus-client-derive-encode@0.4.2
	quote@1.0.36
	radium@0.7.0
	redox_syscall@0.4.1
	redox_syscall@0.5.1
	regex@1.10.4
	regex-automata@0.4.6
	regex-syntax@0.6.29
	regex-syntax@0.8.3
	rlimit@0.10.1
	rustc-hash@1.1.0
	rustix@0.38.34
	rustversion@1.0.17
	ryu@1.0.18
	same-file@1.0.6
	scopeguard@1.2.0
	scroll@0.11.0
	scroll_derive@0.11.1
	semver@1.0.23
	serde@1.0.203
	serde_derive@1.0.203
	serde_json@1.0.117
	shlex@1.3.0
	simplelog@0.12.2
	smallvec@1.13.2
	sorted-vec@0.8.3
	sscanf@0.4.1
	sscanf_macro@0.4.1
	static_assertions@1.1.0
	strsim@0.10.0
	strsim@0.11.1
	strum_macros@0.24.3
	syn@1.0.109
	syn@2.0.66
	tap@1.0.1
	tar@0.4.41
	tempfile@3.10.1
	termcolor@1.4.1
	terminal_size@0.3.0
	thiserror@1.0.61
	thiserror-impl@1.0.61
	threadpool@1.8.1
	time@0.3.36
	time-core@0.1.2
	time-macros@0.2.18
	toml_datetime@0.6.6
	toml_edit@0.19.15
	unicase@2.7.0
	unicode-ident@1.0.12
	unicode-segmentation@1.11.0
	unicode-width@0.1.13
	unicode-xid@0.2.4
	utf8parse@0.2.1
	version_check@0.9.4
	version-compare@0.1.1
	vsprintf@2.0.0
	walkdir@2.5.0
	which@4.4.2
	winapi-util@0.1.8
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.5
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.5
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.5
	windows_i686_gnullvm@0.52.5
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.5
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-targets@0.48.5
	windows-targets@0.52.5
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.5
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.5
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.5
	winnow@0.5.40
	wyz@0.5.1
	xattr@1.3.1
"

LLVM_COMPAT=( 17 18 )

# we need to bundle bpftool for skeleton support
# these are just for the build, scx scheds will link
# to system libbpf
BPFTOOLV="20ce6933869b70bacfdd0dd1a8399199290bf8ff"
LIBBPFV="20ea95b4505c477af3b6ff6ce9d19cee868ddc5d"

inherit linux-info llvm-r1 cargo meson

DESCRIPTION="sched_ext schedulers and tools"
HOMEPAGE="https://github.com/sched-ext/scx"
SRC_URI="
	https://github.com/sched-ext/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/libbpf/bpftool/archive/${BPFTOOLV}.tar.gz -> bpftool-${BPFTOOLV}.tar.gz
	https://github.com/libbpf/libbpf/archive/${LIBBPFV}.tar.gz -> bpftool-${LIBBPFV}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug openrc systemd"

BDEPEND="
	app-misc/jq
	sys-kernel/linux-headers
	virtual/pkgconfig
	$(llvm_gen_dep '
		sys-devel/clang:${LLVM_SLOT}[llvm_targets_BPF]
		virtual/rust:0/llvm-${LLVM_SLOT}
	')
"
DEPEND="
	>=dev-libs/libbpf-1.3.0
	>=dev-util/bpftool-6.8
	openrc? ( sys-apps/openrc )
	systemd? ( sys-apps/systemd )
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/0.1.8-clang-libcxx.patch" )

CONFIG_CHECK="
	~BPF
	~BPF_EVENTS
	~BPF_JIT
	~BPF_SYSCALL
	~DEBUG_INFO_BTF
	~FTRACE
	~SCHED_CLASS_EXT
"
COMMON_WARN_BPF="
The following kernel config settings need to be enabled
in order to load userspace schedulers:
	${CONFIG_CHECK//\~/CONFIG_}"
WARNING_BPF="${COMMON_WARN_BPF}"
WARNING_BPF_EVENTS="${COMMON_WARN_BPF}"
WARNING_BPF_JIT="${COMMON_WARN_BPF}"
WARNING_BPF_SYSCALL="${COMMON_WARN_BPF}"
WARNING_DEBUG_INFO_BTF="${COMMON_WARN_BPF}"
WARNING_FTRACE="${COMMON_WARN_BPF}"
WARNING_SCHED_CLASS_EXT="
Make sure your kernel includes the sched-ext
patchset and enables SCHED_CLASS_EXT!

Kernels including this are:
	sys-kernel/cachyos-kernel (USE cachyos or sched-ext)
"

# default but already needed in src_prepare
BUILD_DIR="${WORKDIR}/${P}-build"

pkg_setup() {
	linux-info_pkg_setup
	llvm-r1_pkg_setup
}

src_prepare() {
	default

	# handle the bpftool fetching logic via ebuild
	echo "#!/bin/sh" > meson-scripts/fetch_bpftool || die
	mkdir -p "${BUILD_DIR}" || die
	mv "${WORKDIR}/bpftool-${BPFTOOLV}" "${BUILD_DIR}/bpftool" || die
	rm -r "${BUILD_DIR}/bpftool/libbpf" || die
	mv "${WORKDIR}/libbpf-${LIBBPFV}" "${BUILD_DIR}/bpftool/libbpf" || die
}

src_configure() {
	local EMESON_BUILDTYPE="$(usex debug debug release)"
	local emesonargs=(
		-Dlibbpf_a=disabled
		-Doffline=true
		-Dlibalpm=disabled
		$(meson_feature openrc)
		$(meson_feature systemd)
	)
	meson_src_configure
}
