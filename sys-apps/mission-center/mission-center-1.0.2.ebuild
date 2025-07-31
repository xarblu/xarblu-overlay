# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# combined crates from
# git clean -fdx
# for i in $(fd Cargo.toml); do dir="./${i%Cargo.toml}"; pycargoebuild "${dir}"; done
# cat *.ebuild | perl -n0e 'while ($_ =~ /CRATES="(.*?)"/gms) { print "$1" }' | sort -u
CRATES="
	addr2line@0.24.2
	adler2@2.0.0
	aho-corasick@1.1.3
	anstream@0.6.18
	anstyle@1.0.10
	anstyle-parse@0.2.6
	anstyle-query@1.1.2
	anstyle-wincon@3.0.7
	anyhow@1.0.98
	app-rummage@0.2.8
	arrayvec@0.7.6
	ash@0.38.0+1.3.281
	async-broadcast@0.7.2
	async-channel@2.3.1
	async-executor@1.13.2
	async-io@2.4.0
	async-lock@3.4.0
	async-process@2.3.0
	async-recursion@1.1.1
	async-signal@0.2.10
	async-task@4.7.1
	async-trait@0.1.88
	atomic-waker@1.1.2
	autocfg@1.4.0
	backtrace@0.3.75
	base64@0.22.1
	bincode@1.3.3
	bitflags@1.3.2
	bitflags@2.9.0
	bitflags@2.9.1
	block@0.1.6
	block-buffer@0.10.4
	blocking@1.6.1
	bmart@0.2.12
	bmart-derive@0.1.4
	bstr@1.12.0
	bytemuck@1.23.0
	bytemuck_derive@1.9.3
	bytes@1.10.1
	cairo-rs@0.20.7
	cairo-sys-rs@0.20.7
	cargo-util@0.2.20
	cc@1.2.20
	cc@1.2.23
	cfg_aliases@0.2.1
	cfg-expr@0.17.2
	cfg-if@1.0.0
	clap@4.5.38
	clap_builder@4.5.38
	clap_derive@4.5.32
	clap_lex@0.7.4
	cmake@0.1.54
	colorchoice@1.0.3
	colored@1.9.4
	concurrent-queue@2.5.0
	const-random@0.1.18
	const-random-macro@0.1.16
	core-foundation@0.10.0
	core-foundation-sys@0.8.7
	cpufeatures@0.2.17
	crc32fast@1.4.2
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crunchy@0.2.3
	crypto-common@0.1.6
	digest@0.10.7
	dlv-list@0.5.2
	drm@0.14.1
	drm-ffi@0.9.0
	drm-fourcc@2.2.0
	drm-sys@0.8.0
	either@1.15.0
	endi@1.1.0
	enumflags2@0.7.11
	enumflags2_derive@0.7.11
	env_filter@0.1.3
	env_logger@0.11.8
	equivalent@1.0.2
	errno@0.3.11
	errno@0.3.12
	error-code@3.3.1
	event-listener@5.4.0
	event-listener-strategy@0.5.4
	fallible-iterator@0.3.0
	fallible-streaming-iterator@0.1.9
	fastrand@2.3.0
	field-offset@0.3.6
	filetime@0.2.25
	fixedbitset@0.5.7
	flate2@1.1.1
	fnv@1.0.7
	foldhash@0.1.5
	futures-channel@0.3.31
	futures-core@0.3.31
	futures-executor@0.3.31
	futures-io@0.3.31
	futures-lite@2.6.0
	futures-macro@0.3.31
	futures-task@0.3.31
	futures-util@0.3.31
	gbm@0.18.0
	gbm-sys@0.4.0
	gdk4@0.9.6
	gdk4-sys@0.9.6
	gdk-pixbuf@0.20.9
	gdk-pixbuf-sys@0.20.7
	generic-array@0.14.7
	getrandom@0.2.16
	getrandom@0.3.2
	getrandom@0.3.3
	gettext-rs@0.7.2
	gettext-sys@0.22.5
	gimli@0.31.1
	gio@0.20.9
	gio-sys@0.20.9
	glib@0.20.9
	glib-macros@0.20.7
	glib-sys@0.20.9
	glob@0.3.2
	globset@0.4.16
	gobject-sys@0.20.9
	graphene-rs@0.20.9
	graphene-sys@0.20.7
	gsk4@0.9.6
	gsk4-sys@0.9.6
	gtk4@0.9.6
	gtk4-macros@0.9.5
	gtk4-sys@0.9.6
	hashbrown@0.14.5
	hashbrown@0.15.2
	hashbrown@0.15.3
	hashlink@0.10.0
	heck@0.5.0
	hermit-abi@0.4.0
	hermit-abi@0.5.1
	hex@0.4.3
	http@1.3.1
	httparse@1.10.1
	ignore@0.4.23
	indexmap@2.9.0
	is-terminal@0.4.16
	is_terminal_polyfill@1.70.1
	itertools@0.14.0
	itoa@1.0.15
	jiff@0.2.13
	jiff-static@0.2.13
	jobserver@0.1.33
	khronos-egl@6.0.0
	lazy_static@1.5.0
	libadwaita@0.7.2
	libadwaita-sys@0.7.2
	libc@0.2.172
	libloading@0.8.7
	libredox@0.1.3
	libsqlite3-sys@0.33.0
	linux-raw-sys@0.4.15
	linux-raw-sys@0.6.5
	linux-raw-sys@0.9.4
	locale_config@0.3.0
	lock_api@0.4.12
	log@0.4.27
	malloc_buf@0.0.6
	matchers@0.1.0
	memchr@2.7.4
	memoffset@0.6.5
	memoffset@0.9.1
	miniz_oxide@0.8.8
	mio@1.0.3
	miow@0.6.0
	multimap@0.10.0
	multimap@0.10.1
	nix@0.22.3
	nix@0.30.1
	nng-c@1.10.1
	nng-c-sys@1.10.1
	ntapi@0.4.1
	nu-ansi-term@0.46.0
	objc@0.2.7
	objc2-core-foundation@0.3.1
	objc2-io-kit@0.3.1
	objc-foundation@0.1.1
	objc_id@0.1.1
	object@0.36.7
	once_cell@1.21.3
	ordered-multimap@0.7.3
	ordered-stream@0.2.0
	overload@0.1.1
	pango@0.20.9
	pango-sys@0.20.9
	parking@2.2.1
	parking_lot@0.12.3
	parking_lot_core@0.9.10
	percent-encoding@2.3.1
	petgraph@0.7.1
	phf@0.11.3
	phf_generator@0.11.3
	phf_macros@0.11.3
	phf_shared@0.11.3
	pin-project-lite@0.2.16
	pin-utils@0.1.0
	piper@0.2.4
	pkg-config@0.3.32
	polling@3.7.4
	portable-atomic@1.11.0
	portable-atomic-util@0.2.4
	ppv-lite86@0.2.21
	prettyplease@0.2.32
	proc-macro2@1.0.95
	proc-macro-crate@3.3.0
	prost@0.13.5
	prost-build@0.13.5
	prost-derive@0.13.5
	prost-types@0.13.5
	quote@1.0.40
	rand@0.8.5
	rand@0.9.1
	rand_chacha@0.9.0
	rand_core@0.6.4
	rand_core@0.9.3
	rayon@1.10.0
	rayon-core@1.12.1
	redox_syscall@0.5.12
	r-efi@5.2.0
	regex@1.11.1
	regex-automata@0.1.10
	regex-automata@0.4.9
	regex-syntax@0.6.29
	regex-syntax@0.8.5
	ring@0.17.14
	rusqlite@0.35.0
	rustc-demangle@0.1.24
	rustc_version@0.4.1
	rust-ini@0.21.1
	rustix@0.38.44
	rustix@1.0.5
	rustix@1.0.7
	rustix-openpty@0.2.0
	rustls@0.23.27
	rustls-pemfile@2.2.0
	rustls-pki-types@1.12.0
	rustls-webpki@0.103.3
	rustversion@1.0.20
	ryu@1.0.20
	same-file@1.0.6
	scopeguard@1.2.0
	semver@1.0.26
	serde@1.0.219
	serde_derive@1.0.219
	serde_json@1.0.140
	serde_repr@0.1.20
	serde_spanned@0.6.8
	sha2@0.10.9
	sharded-slab@0.1.7
	shell-escape@0.1.5
	shlex@1.3.0
	signal-hook@0.3.18
	signal-hook-registry@1.4.5
	siphasher@1.0.1
	slab@0.4.9
	smallvec@1.15.0
	socket2@0.5.9
	static_assertions@1.1.0
	strsim@0.11.1
	strum@0.26.3
	strum_macros@0.26.4
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.101
	sysinfo@0.29.11
	sysinfo@0.35.1
	system-deps@7.0.3
	tar@0.4.44
	target-lexicon@0.12.16
	temp-dir@0.1.14
	temp-dir@0.1.16
	tempfile@3.19.1
	tempfile@3.20.0
	test-log@0.2.17
	test-log-macros@0.2.17
	textdistance@1.1.1
	thiserror@2.0.12
	thiserror-impl@2.0.12
	thread_local@1.1.8
	tiny-keccak@2.0.2
	tokio@1.45.0
	tokio-macros@2.5.0
	toml@0.8.22
	toml_datetime@0.6.9
	toml_edit@0.22.26
	tracing@0.1.41
	tracing-attributes@0.1.28
	tracing-core@0.1.33
	tracing-log@0.2.0
	tracing-subscriber@0.3.19
	triggered@0.1.3
	trim-in-place@0.1.7
	typenum@1.18.0
	udisks2@0.3.1
	uds_windows@1.1.0
	unicode-ident@1.0.18
	unicode-width@0.1.14
	untrusted@0.9.0
	ureq@3.0.11
	ureq-proto@0.4.1
	utf-8@0.7.6
	utf8parse@0.2.2
	uuid@0.8.2
	valuable@0.1.1
	vcpkg@0.2.15
	version_check@0.9.5
	version-compare@0.2.0
	virtual-terminal@0.1.4
	vt100@0.15.2
	vte@0.11.1
	vte_generate_state_changes@0.1.2
	walkdir@2.5.0
	wasi@0.11.0+wasi-snapshot-preview1
	wasi@0.14.2+wasi-0.2.4
	webpki-roots@0.26.11
	webpki-roots@1.0.0
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.9
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows@0.61.1
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.0
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.0
	windows-collections@0.2.0
	windows-core@0.61.1
	windows-future@0.2.1
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.0
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.0
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.0
	windows-implement@0.60.0
	windows-interface@0.59.1
	windows-link@0.1.1
	windows-numerics@0.2.0
	windows-result@0.3.3
	windows-strings@0.4.1
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows-targets@0.53.0
	windows-threading@0.1.0
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.0
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.0
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.0
	winnow@0.7.10
	winnow@0.7.7
	wit-bindgen-rt@0.39.0
	xattr@1.5.0
	zbus@5.7.0
	zbus_macros@5.7.0
	zbus_names@4.2.0
	zerocopy@0.8.25
	zerocopy-derive@0.8.25
	zeroize@1.8.1
	zvariant@5.5.3
	zvariant_derive@5.5.3
	zvariant_utils@3.2.0
"

PYTHON_COMPAT=( python3_{11..13} )

# subprojects/magpie
MAGPIE_COMMIT="319d95d29cbc3c373ae61cff228e8440fbaadbbb"
# subprojects/magpie/platform-linux/3rdparty/nvtop/nvtop.json
NVTOP_COMMIT="73291884d926445e499d6b9b71cb7a9bdbc7c393"

# cargo + meson for src_* (explicit)
# gnome2 for pkg_{preinst,postinst,postrm} (implicit)
# python-any-r1 for build time python dep
inherit cargo gnome2 meson python-any-r1

DESCRIPTION="Monitor your CPU, Memory, Disk, Network and GPU usage."
HOMEPAGE="https://missioncenter.io/"

SRC_URI="
	https://gitlab.com/mission-center-devs/mission-center/-/archive/v${PV}/${PN}-v${PV}.tar.bz2
		-> ${P}.tar.bz2
	https://gitlab.com/mission-center-devs/gng/-/archive/${MAGPIE_COMMIT}/${PN}-v${PV}-magpie.tar.bz2
		-> ${P}-magpie.tar.bz2
	https://github.com/Syllo/nvtop/archive/${NVTOP_COMMIT}.tar.gz
		-> ${P}-nvtop.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${PN}-v${PV}"
LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions Boost-1.0 CC0-1.0 MIT
	Unicode-3.0
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

DEPEND="
	>=dev-libs/appstream-0.16.4
	>=dev-libs/glib-2.80
	>=dev-util/gdbus-codegen-2.80
	>=gui-libs/gtk-4.18.0
	>=gui-libs/libadwaita-1.7.0
	>=x11-libs/pango-1.51.0
	dev-libs/protobuf:=
	dev-libs/wayland
	gui-libs/egl-gbm
	virtual/udev
	x11-libs/libdrm
"
RDEPEND="
	net-analyzer/nethogs
	sys-apps/dmidecode
	${DEPEND}
"
BDEPEND="
	>=dev-build/meson-0.63
	dev-libs/gobject-introspection
	dev-util/blueprint-compiler
	${PYTHON_DEPS}
"

# rust does not use *FLAGS from make.conf, silence portage warning
# update with proper path to binaries this crate installs, omit leading /
QA_FLAGS_IGNORED="
	usr/bin/missioncenter
	usr/bin/missioncenter-magpie
"

PATCHES=(
	"${FILESDIR}/1.0.0-respect-cargo-home.patch"
)

# meson.eclass default but needs to be set early for src_prepare
BUILD_DIR="${WORKDIR}/${P}-build"

src_prepare() {
	# move magpie into subproject
	rmdir subprojects/magpie || die
	mv "${WORKDIR}/gng-${MAGPIE_COMMIT}" subprojects/magpie || die

	# patch nvtop and move into build dir
	pushd "${WORKDIR}/nvtop-${NVTOP_COMMIT}" >/dev/null || die
	eapply "${S}/subprojects/magpie/platform-linux/3rdparty/nvtop/patches"
	popd >/dev/null || die
	local nvtop_dest="${BUILD_DIR}/subprojects/magpie/src/$(usex debug debug release)/build/native"
	mkdir -p "${nvtop_dest}" || die
	mv "${WORKDIR}/nvtop-${NVTOP_COMMIT}" "${nvtop_dest}" || die

	default
}

src_configure() {
	local EMESON_BUILDTYPE=$(usex debug debug release)
	cargo_env meson_src_configure
}

src_compile() {
	cargo_env meson_src_compile
}

src_test() {
	cargo_env meson_src_test
}

src_install() {
	cargo_env meson_src_install
}
