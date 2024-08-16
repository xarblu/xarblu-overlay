# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# combined crate deps of all rust subprojects
# git clean -f; for i in `fd Cargo.toml`; do pushd "${i%/*}"; cargo update; popd; pycargoebuild "${i%/*}"; done; cat *.ebuild | perl -n0e 'print "$1" while /CRATES="\n(.*?)"/gms' | sort -u | tee scx-crate-deps
CRATES="
	addr2line@0.22.0
	adler@1.0.2
	ahash@0.8.11
	aho-corasick@1.1.3
	anstream@0.6.15
	anstyle@1.0.8
	anstyle-parse@0.2.5
	anstyle-query@1.1.1
	anstyle-wincon@3.0.4
	anyhow@1.0.86
	atomic-waker@1.1.2
	autocfg@1.3.0
	aws-lc-rs@1.8.1
	aws-lc-sys@0.20.1
	backtrace@0.3.73
	base64@0.22.1
	bindgen@0.69.4
	bitflags@1.3.2
	bitflags@2.6.0
	bitvec@1.0.1
	bumpalo@3.16.0
	bytes@1.7.1
	camino@1.1.7
	cargo_metadata@0.15.4
	cargo_metadata@0.18.1
	cargo-platform@0.1.8
	cc@1.1.12
	cexpr@0.6.0
	cfg_aliases@0.1.1
	cfg_aliases@0.2.1
	cfg-if@1.0.0
	cgroupfs@0.7.1
	clang-sys@1.8.1
	clap@4.5.15
	clap_builder@4.5.15
	clap_derive@4.5.13
	clap_lex@0.7.2
	cmake@0.1.51
	colorchoice@1.0.2
	const_format@0.2.31
	const_format_proc_macros@0.2.31
	convert_case@0.6.0
	core-foundation@0.9.4
	core-foundation-sys@0.8.7
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.20
	ctrlc@3.4.5
	deranged@0.3.11
	dtoa@1.0.9
	dunce@1.0.5
	either@1.13.0
	endian-type@0.1.2
	equivalent@1.0.1
	errno@0.3.9
	fastrand@2.1.0
	fb_procfs@0.7.1
	filetime@0.2.24
	fnv@1.0.7
	fs_extra@1.3.0
	funty@2.0.0
	futures-channel@0.3.30
	futures-core@0.3.30
	futures-sink@0.3.30
	futures-task@0.3.30
	futures-util@0.3.30
	getrandom@0.2.15
	gimli@0.29.0
	glob@0.3.1
	h2@0.4.5
	hashbrown@0.14.5
	heck@0.4.1
	heck@0.5.0
	hermit-abi@0.3.9
	hex@0.4.3
	home@0.5.9
	http@1.1.0
	httparse@1.9.4
	http-body@1.0.1
	http-body-util@0.1.2
	httpdate@1.0.3
	hyper@1.4.1
	hyper-rustls@0.27.2
	hyper-util@0.1.7
	indexmap@2.4.0
	ipnet@2.9.0
	is_terminal_polyfill@1.70.1
	itertools@0.12.1
	itoa@1.0.11
	jobserver@0.1.32
	js-sys@0.3.70
	lazycell@1.3.0
	lazy_static@1.5.0
	libbpf-cargo@0.23.3
	libbpf-rs@0.23.3
	libbpf-sys@1.4.3+v1.4.5
	libc@0.2.155
	libloading@0.8.5
	libredox@0.1.3
	linux-raw-sys@0.4.14
	lock_api@0.4.12
	log@0.4.22
	maplit@1.0.2
	memchr@2.7.4
	memmap2@0.5.10
	memoffset@0.6.5
	metrics@0.23.0
	metrics-exporter-prometheus@0.15.3
	metrics-util@0.17.0
	minimal-lexical@0.2.1
	miniz_oxide@0.7.4
	mio@1.0.2
	mirai-annotations@1.12.0
	nibble_vec@0.1.0
	nix@0.25.1
	nix@0.28.0
	nix@0.29.0
	nom@7.1.3
	num-conv@0.1.0
	num_cpus@1.16.0
	num_threads@0.1.7
	num-traits@0.2.19
	object@0.36.3
	once_cell@1.19.0
	openat@0.1.21
	openssl-probe@0.1.5
	ordered-float@3.9.2
	ordered-float@4.2.2
	parking_lot@0.12.3
	parking_lot_core@0.9.10
	paste@1.0.15
	pin-project@1.1.5
	pin-project-internal@1.1.5
	pin-project-lite@0.2.14
	pin-utils@0.1.0
	pkg-config@0.3.30
	plain@0.2.3
	portable-atomic@1.7.0
	powerfmt@0.2.0
	prettyplease@0.2.20
	proc-macro2@1.0.86
	prometheus-client@0.19.0
	prometheus-client-derive-encode@0.4.2
	quanta@0.12.3
	quote@1.0.36
	radium@0.7.0
	radix_trie@0.2.1
	raw-cpuid@11.1.0
	redox_syscall@0.5.3
	regex@1.10.6
	regex-automata@0.4.7
	regex-syntax@0.6.29
	regex-syntax@0.8.4
	ring@0.17.8
	rlimit@0.10.1
	rustc-demangle@0.1.24
	rustc-hash@1.1.0
	rustix@0.38.34
	rustls@0.23.12
	rustls-native-certs@0.7.1
	rustls-pemfile@2.1.3
	rustls-pki-types@1.8.0
	rustls-webpki@0.102.6
	rustversion@1.0.17
	ryu@1.0.18
	same-file@1.0.6
	schannel@0.1.23
	scopeguard@1.2.0
	security-framework@2.11.1
	security-framework-sys@2.11.1
	semver@1.0.23
	serde@1.0.208
	serde_derive@1.0.208
	serde_json@1.0.125
	shlex@1.3.0
	simplelog@0.12.2
	sketches-ddsketch@0.2.2
	slab@0.4.9
	smallvec@1.13.2
	socket2@0.5.7
	sorted-vec@0.8.3
	spin@0.9.8
	sscanf@0.4.2
	sscanf_macro@0.4.2
	static_assertions@1.1.0
	strsim@0.10.0
	strsim@0.11.1
	strum_macros@0.24.3
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.74
	tap@1.0.1
	tar@0.4.41
	tempfile@3.12.0
	termcolor@1.4.1
	terminal_size@0.3.0
	thiserror@1.0.63
	thiserror-impl@1.0.63
	threadpool@1.8.1
	time@0.3.36
	time-core@0.1.2
	time-macros@0.2.18
	tokio@1.39.2
	tokio-rustls@0.26.0
	tokio-util@0.7.11
	tower@0.4.13
	tower-layer@0.3.3
	tower-service@0.3.3
	tracing@0.1.40
	tracing-attributes@0.1.27
	tracing-core@0.1.32
	try-lock@0.2.5
	unicase@2.7.0
	unicode-ident@1.0.12
	unicode-segmentation@1.11.0
	unicode-width@0.1.12
	unicode-xid@0.2.4
	untrusted@0.9.0
	utf8parse@0.2.2
	vergen@8.3.2
	version_check@0.9.5
	version-compare@0.1.1
	vsprintf@2.0.0
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.0+wasi-snapshot-preview1
	wasm-bindgen@0.2.93
	wasm-bindgen-backend@0.2.93
	wasm-bindgen-macro@0.2.93
	wasm-bindgen-macro-support@0.2.93
	wasm-bindgen-shared@0.2.93
	web-sys@0.3.70
	which@4.4.2
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.9
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
	wyz@0.5.1
	xattr@1.3.1
	zerocopy@0.7.35
	zerocopy-derive@0.7.35
	zeroize@1.8.1
	zeroize_derive@1.4.2
"

LLVM_COMPAT=( 17 18 )

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
	>=dev-util/bpftool-7.5.0
	openrc? ( sys-apps/openrc )
	systemd? ( sys-apps/systemd )
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/1.0.2.cargo-dep.patch" #https://github.com/sched-ext/scx/commit/099b6c266a37c7af5a066c100d6331f33968d1d4
)

CONFIG_CHECK="
	~BPF
	~BPF_EVENTS
	~BPF_JIT
	~BPF_SYSCALL
	~DEBUG_KERNEL
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
WARNING_DEBUG_KERNEL="${COMMON_WARN_BPF}"
WARNING_DEBUG_INFO_BTF="${COMMON_WARN_BPF}"
WARNING_FTRACE="${COMMON_WARN_BPF}"
WARNING_SCHED_CLASS_EXT="
Make sure your kernel includes the sched-ext
patchset and enables SCHED_CLASS_EXT!

Kernels including this are:
	sys-kernel/cachyos-kernel (USE cachyos or sched-ext)
"

pkg_setup() {
	linux-info_pkg_setup
	llvm-r1_pkg_setup
}

src_configure() {
	local EMESON_BUILDTYPE="$(usex debug debug release)"
	local emesonargs=(
		-Dbpftool=disabled
		-Dlibbpf_a=disabled
		-Doffline=true
		-Dlibalpm=disabled
		$(meson_feature openrc)
		$(meson_feature systemd)
	)
	meson_src_configure
}
