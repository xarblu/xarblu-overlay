# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

# combined crates from
# git clean -fdx
# for i in $(fd Cargo.toml); do dir="./${i%Cargo.toml}"; pycargoebuild -f "${dir}"; done
# cat *.ebuild | perl -n0e 'while ($_ =~ /CRATES="(.*?)"/gms) { print "$1" }' | sort -u
CRATES="
	adler2@2.0.1
	ahash@0.8.12
	aho-corasick@1.1.4
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.104
	arrayvec@0.7.8
	ash@0.38.0+1.3.281
	async-broadcast@0.7.2
	async-channel@2.5.0
	async-executor@1.14.0
	async-io@2.6.0
	async-lock@3.4.2
	async-process@2.5.0
	async-recursion@1.1.1
	async-signal@0.2.14
	async-task@4.7.1
	async-trait@0.1.91
	atomic-waker@1.1.2
	autocfg@1.5.1
	base64@0.22.1
	beef@0.5.2
	bitcode@0.6.9
	bitcode_derive@0.6.9
	bitfield-macros@0.19.4
	bitfield@0.19.4
	bitflags@1.3.2
	bitflags@2.13.1
	block-buffer@0.12.1
	block@0.1.6
	blocking@1.6.2
	bmart-derive@0.1.4
	bmart@0.2.12
	bstr@1.13.0
	bumpalo@3.20.3
	bytemuck@1.25.2
	bytemuck_derive@1.11.0
	bytes@1.12.1
	cairo-rs@0.22.0
	cairo-sys-rs@0.22.0
	cargo-util@0.2.30
	cc@1.3.0
	cfg-expr@0.20.8
	cfg-if@1.0.4
	cfg_aliases@0.2.2
	chacha20@0.10.1
	clap@4.6.3
	clap_builder@4.6.2
	clap_derive@4.6.3
	clap_lex@1.1.0
	cmake@0.1.58
	colorchoice@1.0.5
	colored@1.9.4
	concurrent-queue@2.5.0
	const-oid@0.10.2
	const-random-macro@0.1.16
	const-random@0.1.18
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	cpufeatures@0.3.0
	crc32fast@1.5.0
	crossbeam-deque@0.8.7
	crossbeam-epoch@0.9.20
	crossbeam-utils@0.8.22
	crunchy@0.2.4
	crypto-common@0.2.2
	defmt-macros@1.1.1
	defmt-parser@1.0.0
	defmt@1.1.1
	digest@0.11.3
	dirs-sys@0.4.1
	dirs@5.0.1
	displaydoc@0.2.6
	dlv-list@0.5.2
	drm-ffi@0.9.1
	drm-fourcc@2.2.0
	drm-sys@0.8.1
	drm@0.14.1
	either@1.16.0
	endi@1.1.1
	enumflags2@0.7.12
	enumflags2_derive@0.7.12
	env_filter@2.0.0
	env_logger@0.11.11
	equivalent@1.0.2
	errno@0.3.14
	error-code@3.3.2
	event-listener-strategy@0.5.4
	event-listener@5.4.1
	fallible-iterator@0.3.0
	fallible-streaming-iterator@0.1.9
	fastrand@2.5.0
	field-offset@0.3.6
	filetime@0.2.29
	find-msvc-tools@0.1.9
	fixedbitset@0.5.7
	flate2@1.1.9
	fluent-bundle@0.16.0
	fluent-langneg@0.13.1
	fluent-syntax@0.12.0
	fluent@0.17.0
	fnv@1.0.7
	foldhash@0.1.5
	foldhash@0.2.0
	freedesktop-icons@0.4.0
	futures-channel@0.3.33
	futures-core@0.3.33
	futures-executor@0.3.33
	futures-io@0.3.33
	futures-lite@2.6.1
	futures-macro@0.3.33
	futures-sink@0.3.33
	futures-task@0.3.33
	futures-util@0.3.33
	futures@0.3.33
	gbm-sys@0.4.0
	gbm@0.18.0
	gdk-pixbuf-sys@0.22.0
	gdk-pixbuf@0.22.0
	gdk4-sys@0.11.4
	gdk4@0.11.4
	getrandom@0.2.17
	getrandom@0.4.3
	gettext-rs@0.7.7
	gettext-sys@0.26.0
	gio-sys@0.22.8
	gio@0.22.8
	glam@0.33.2
	glib-macros@0.22.6
	glib-sys@0.22.8
	glib@0.22.8
	glob@0.3.3
	globset@0.4.19
	gobject-sys@0.22.6
	graphene-rs@0.22.8
	graphene-sys@0.22.8
	gsk4-sys@0.11.4
	gsk4@0.11.4
	gtk4-macros@0.11.4
	gtk4-sys@0.11.4
	gtk4@0.11.4
	hashbrown@0.14.5
	hashbrown@0.15.5
	hashbrown@0.16.1
	hashbrown@0.17.1
	hashlink@0.12.1
	heck@0.5.0
	hermit-abi@0.5.2
	hex@0.4.3
	http@1.4.2
	httparse@1.10.1
	hybrid-array@0.4.13
	ignore@0.4.31
	indexmap@2.14.0
	ini_core@0.2.0
	intl-memoizer@0.5.3
	intl_pluralrules@7.0.2
	is-terminal@0.4.17
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	itoa@1.0.18
	jiff-core@0.1.0
	jiff-static@0.2.34
	jiff@0.2.34
	jobserver@0.1.35
	js-sys@0.3.103
	khronos-egl@6.0.0
	lazy_static@1.5.0
	libadwaita-sys@0.9.2
	libadwaita@0.9.2
	libc@0.2.187
	libloading@0.8.9
	libredox@0.1.18
	libsqlite3-sys@0.38.1
	linux-raw-sys@0.12.1
	linux-raw-sys@0.4.15
	linux-raw-sys@0.9.4
	locale_config@0.3.0
	lock_api@0.4.14
	log@0.4.33
	logos-codegen@0.15.1
	logos-codegen@0.16.1
	logos-derive@0.15.1
	logos-derive@0.16.1
	logos@0.15.1
	logos@0.16.1
	malloc_buf@0.0.6
	matchers@0.2.0
	memchr@2.8.3
	memoffset@0.6.5
	memoffset@0.9.1
	miette-derive@7.6.0
	miette@7.6.0
	miniz_oxide@0.8.9
	mio@1.2.2
	miow@0.6.1
	multimap@0.10.1
	nix@0.22.3
	nix@0.31.3
	nng-c-sys@1.11.1
	nng-c@1.11.1
	ntapi@0.4.3
	nu-ansi-term@0.50.3
	objc-foundation@0.1.1
	objc2-core-foundation@0.3.2
	objc2-io-kit@0.3.2
	objc@0.2.7
	objc_id@0.1.1
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	option-ext@0.2.0
	ordered-multimap@0.7.3
	ordered-stream@0.2.0
	os_display@0.1.4
	pango-sys@0.22.0
	pango@0.22.8
	parking@2.2.1
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	percent-encoding@2.3.2
	petgraph@0.8.3
	phf@0.14.0
	phf_generator@0.14.0
	phf_macros@0.14.0
	phf_shared@0.14.0
	pin-project-lite@0.2.17
	piper@0.2.5
	pkg-config@0.3.33
	polling@3.11.0
	portable-atomic-util@0.2.7
	portable-atomic@1.14.0
	prettyplease@0.2.37
	proc-macro-crate@3.5.0
	proc-macro2@1.0.107
	prost-build@0.14.4
	prost-derive@0.14.4
	prost-reflect@0.16.5
	prost-types@0.14.4
	prost@0.14.4
	protox-parse@0.9.0
	protox@0.9.1
	quote@1.0.47
	r-efi@6.0.0
	rand@0.10.2
	rand_core@0.10.1
	rayon-core@1.13.0
	rayon@1.12.0
	redox_syscall@0.5.18
	redox_users@0.4.6
	regex-automata@0.4.16
	regex-syntax@0.8.11
	regex@1.13.1
	ring@0.17.14
	rsqlite-vfs@0.1.1
	rusqlite@0.40.1
	rust-ini@0.21.3
	rustc-hash@2.1.3
	rustc_version@0.4.1
	rustix-openpty@0.2.0
	rustix@0.38.44
	rustix@1.1.4
	rustls-pki-types@1.15.0
	rustls-webpki@0.103.13
	rustls@0.23.42
	rustversion@1.0.23
	same-file@1.0.6
	scopeguard@1.2.0
	self_cell@1.3.0
	semver@1.0.28
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.151
	serde_repr@0.1.21
	serde_spanned@1.1.1
	sha2@0.11.0
	sharded-slab@0.1.7
	shell-escape@0.1.5
	shlex@2.0.1
	signal-hook-registry@1.4.8
	signal-hook@0.4.4
	simd-adler32@0.3.10
	siphasher@1.0.3
	slab@0.4.12
	smallvec@1.15.2
	socket2@0.6.5
	sqlite-wasm-rs@0.5.5
	strsim@0.11.1
	strum@0.28.0
	strum_macros@0.28.0
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.119
	syn@3.0.2
	sysinfo@0.29.11
	sysinfo@0.37.2
	system-deps@7.0.8
	tar@0.4.46
	target-lexicon@0.13.5
	temp-dir@0.1.16
	tempfile@3.27.0
	terminal_size@0.4.4
	test-log-core@0.2.21
	test-log-macros@0.2.21
	test-log@0.2.21
	textdistance@1.1.1
	thiserror-impl@1.0.69
	thiserror-impl@2.0.19
	thiserror@1.0.69
	thiserror@2.0.19
	thread_local@1.1.10
	tiny-keccak@2.0.2
	tinystr@0.8.3
	tokio-macros@2.7.1
	tokio@1.53.1
	toml@1.1.3+spec-1.1.0
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.13+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	toml_writer@1.1.2+spec-1.1.0
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.23
	tracing@0.1.44
	triggered@0.1.3
	trim-in-place@0.1.7
	type-map@0.5.1
	typenum@1.20.1
	udisks2@0.3.1
	uds_windows@1.2.1
	unic-langid-impl@0.9.6
	unic-langid@0.9.6
	unicode-ident@1.0.24
	unicode-width@0.1.14
	unicode-width@0.2.2
	untrusted@0.9.0
	ureq-proto@0.6.0
	ureq@3.3.0
	utf8-zero@0.8.1
	utf8parse@0.2.2
	uucore@0.9.0
	uucore_procs@0.9.0
	uuid@0.8.2
	uuid@1.24.0
	valuable@0.1.1
	vcpkg@0.2.15
	version-compare@0.2.1
	version_check@0.9.5
	virtual-terminal@0.1.5
	vt100@0.16.2
	vte@0.15.0
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasm-bindgen-macro-support@0.2.126
	wasm-bindgen-macro@0.2.126
	wasm-bindgen-shared@0.2.126
	wasm-bindgen@0.2.126
	webpki-roots@1.0.9
	which@8.0.5
	wild@2.2.1
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.2.0
	windows-core@0.61.2
	windows-future@0.2.1
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.1.3
	windows-link@0.2.1
	windows-numerics@0.2.0
	windows-result@0.3.4
	windows-strings@0.4.2
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.61.2
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows-threading@0.1.0
	windows@0.61.3
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
	winnow@1.0.4
	xattr@1.6.1
	xdg@2.5.2
	zbus@5.18.0
	zbus_macros@5.18.0
	zbus_names@4.3.4
	zerocopy-derive@0.8.55
	zerocopy@0.8.55
	zerofrom@0.1.8
	zeroize@1.9.0
	zerovec@0.11.6
	zmij@1.0.23
	zvariant@5.13.1
	zvariant_derive@5.13.1
	zvariant_utils@3.5.0
"

declare -A GIT_CRATES=(
	[upower_dbus]='https://github.com/pop-os/dbus-settings-bindings;87c3c35666b926a24a1e8045fd70be2db1145e34;dbus-settings-bindings-%commit%/upower'
)

PYTHON_COMPAT=( python3_{12..15} )
RUST_MIN_VER="1.90"

# subprojects/magpie
MAGPIE_COMMIT="a5272b3c1d853caa4044b737cf49257bfc4c86f2"
# subprojects/magpie/platform-linux/crates/app-rummage
APP_RUMMAGE_COMMIT="26b93b8c6f0de6912f0a17022f7ece76bad87612"
# subprojects/magpie/platform-linux/3rdparty/nvtop/nvtop.json
NVTOP_COMMIT="3d4a953da02bc18886734613bb9f60ff80669de7"

# cargo + meson for src_* (explicit)
# gnome2 for pkg_{preinst,postinst,postrm} (implicit)
# python-any-r1 for build time python dep
inherit cargo gnome2 meson python-any-r1

DESCRIPTION="Monitor your CPU, Memory, Disk, Network and GPU usage"
HOMEPAGE="https://missioncenter.io/"

SRC_URI="
	https://gitlab.com/mission-center-devs/mission-center/-/archive/v${PV}/${PN}-v${PV}.tar.bz2
		-> ${P}.tar.bz2
	https://gitlab.com/mission-center-devs/gng/-/archive/${MAGPIE_COMMIT}/${PN}-v${PV}-magpie.tar.bz2
		-> ${P}-magpie.tar.bz2
	https://gitlab.com/mission-center-devs/app-detection/-/archive/${APP_RUMMAGE_COMMIT}/app-detection-${APP_RUMMAGE_COMMIT}.tar.bz2
		-> ${P}-app-rummage-${APP_RUMMAGE_COMMIT::8}.tar.bz2
	https://github.com/Syllo/nvtop/archive/${NVTOP_COMMIT}.tar.gz
		-> ${P}-nvtop-${NVTOP_COMMIT::8}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${PN}-v${PV}"
LICENSE="GPL-3"
# Dependent crate licenses (magpie)
LICENSE+="
	Apache-2.0 BSD Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 ISC LGPL-2.1
	MIT MPL-2.0 Unicode-3.0 ZLIB
"
# Dependent crate licenses (missioncenter)
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions Boost-1.0 CC0-1.0 MIT
	Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

DEPEND="
	>=dev-libs/appstream-0.16.4
	>=dev-libs/glib-2.80
	>=dev-util/gdbus-codegen-2.80
	>=gui-libs/gtk-4.22.0
	>=gui-libs/libadwaita-1.9.0
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
	app-misc/jq
	>=dev-build/cmake-3.15.0
	>=dev-build/meson-1.0.2
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
	"${FILESDIR}/1.2.0-respect-cargo-home.patch"
)

# meson.eclass default but needs to be set early for src_prepare
BUILD_DIR="${WORKDIR}/${P}-build"

src_prepare() {
	# magpie subproject
	rmdir subprojects/magpie || die
	mv "${WORKDIR}/gng-${MAGPIE_COMMIT}" subprojects/magpie || die

	# app-rummage subproject
	rmdir subprojects/magpie/platform-linux/crates/app-rummage || die
	mv "${WORKDIR}/app-detection-${APP_RUMMAGE_COMMIT}" subprojects/magpie/platform-linux/crates/app-rummage || die

	# nvtop subproject + patches
	pushd "${WORKDIR}/nvtop-${NVTOP_COMMIT}" >/dev/null || die

	# just to be safe preserve the order defined in nvtop.json
	local patch
	while IFS='' read -r patch; do
		# kinda dirty but nvtop-dont-require-ncurses.patch
		# refuses to apply without fuzz
		eapply --fuzz 3 -- "${patch}"
	done < <(jq -r \
		".patches | map(\"${S}/subprojects/magpie/platform-linux/3rdparty/nvtop/\" + .) | .[]" \
		< "${S}/subprojects/magpie/platform-linux/3rdparty/nvtop/nvtop.json" \
		|| die)

	popd >/dev/null || die

	local nvtop_dest
	nvtop_dest="${BUILD_DIR}/subprojects/magpie/src/$(usex debug debug release)/build/native"
	mkdir -p "${nvtop_dest}" || die
	mv "${WORKDIR}/nvtop-${NVTOP_COMMIT}" "${nvtop_dest}" || die

	default
}

src_configure() {
	local EMESON_BUILDTYPE
	EMESON_BUILDTYPE=$(usex debug debug release)
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
