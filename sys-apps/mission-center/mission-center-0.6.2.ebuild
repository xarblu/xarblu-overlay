# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# combined crates from
# Cargo.toml
# src/sys_info_v2/gatherer/Cargo.toml
CRATES="
	adler2@2.0.0
	ahash@0.8.11
	aho-corasick@1.1.3
	anyhow@1.0.89
	app-rummage@0.2.7
	arrayvec@0.7.6
	ash@0.38.0+1.3.281
	autocfg@1.4.0
	base64@0.22.1
	bincode@1.3.3
	bitflags@2.6.0
	block@0.1.6
	block-buffer@0.10.4
	bstr@1.10.0
	bytemuck@1.18.0
	bytemuck_derive@1.7.1
	cairo-rs@0.20.1
	cairo-sys-rs@0.20.0
	cargo-util@0.2.14
	cc@1.1.28
	cfg_aliases@0.2.1
	cfg-expr@0.17.0
	cfg-if@1.0.0
	const-random@0.1.18
	const-random-macro@0.1.16
	convert_case@0.6.0
	core-foundation@0.9.4
	core-foundation-sys@0.8.7
	cpufeatures@0.2.14
	crc32fast@1.4.2
	crossbeam-deque@0.8.5
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.20
	crunchy@0.2.2
	crypto-common@0.1.6
	dbus@0.9.7
	dbus-crossroads@0.5.2
	digest@0.10.7
	dlv-list@0.5.2
	drm@0.14.0
	drm-ffi@0.9.0
	drm-fourcc@2.2.0
	drm-sys@0.8.0
	egl@0.2.7
	either@1.13.0
	equivalent@1.0.1
	errno@0.3.9
	errno-sys@0.2.0
	fallible-iterator@0.3.0
	fallible-streaming-iterator@0.1.9
	fastrand@2.1.1
	field-offset@0.3.6
	filetime@0.2.25
	flate2@1.0.34
	form_urlencoded@1.2.1
	futures-channel@0.3.31
	futures-core@0.3.31
	futures-executor@0.3.31
	futures-io@0.3.31
	futures-macro@0.3.31
	futures-task@0.3.31
	futures-util@0.3.31
	gbm@0.16.0
	gbm-sys@0.3.1
	gdk4@0.9.2
	gdk4-sys@0.9.2
	gdk-pixbuf@0.20.4
	gdk-pixbuf-sys@0.20.4
	generic-array@0.14.7
	getrandom@0.2.15
	gettext-rs@0.7.1
	gettext-sys@0.21.4
	gio@0.20.4
	gio-sys@0.20.4
	glib@0.20.4
	glib-macros@0.20.4
	glib-sys@0.20.4
	glob@0.3.1
	globset@0.4.15
	gobject-sys@0.20.4
	graphene-rs@0.20.4
	graphene-sys@0.20.4
	gsk4@0.9.2
	gsk4-sys@0.9.2
	gtk4@0.9.2
	gtk4-macros@0.9.1
	gtk4-sys@0.9.2
	hashbrown@0.14.5
	hashbrown@0.15.0
	hashlink@0.9.1
	heck@0.5.0
	hex@0.4.3
	idna@0.5.0
	ignore@0.4.23
	indexmap@2.6.0
	itoa@1.0.11
	jobserver@0.1.32
	khronos@0.1.2
	lazy_static@1.5.0
	libadwaita@0.7.0
	libadwaita-sys@0.7.0
	libc@0.1.12
	libc@0.2.159
	libdbus-sys@0.2.5
	libloading@0.8.5
	libredox@0.1.3
	libsqlite3-sys@0.30.1
	libudev-sys@0.1.4
	linux-raw-sys@0.4.14
	linux-raw-sys@0.6.5
	locale_config@0.3.0
	log@0.4.22
	malloc_buf@0.0.6
	memchr@2.7.4
	memoffset@0.9.1
	miniz_oxide@0.8.0
	miow@0.6.0
	nix@0.29.0
	objc@0.2.7
	objc-foundation@0.1.1
	objc_id@0.1.1
	once_cell@1.20.2
	ordered-multimap@0.7.3
	pango@0.20.4
	pango-sys@0.20.4
	percent-encoding@2.3.1
	pin-project-lite@0.2.14
	pin-utils@0.1.0
	pkg-config@0.3.31
	proc-macro2@1.0.86
	proc-macro-crate@3.2.0
	quote@1.0.37
	rayon@1.10.0
	rayon-core@1.12.1
	redox_syscall@0.5.7
	regex@1.11.0
	regex-automata@0.4.8
	regex-syntax@0.8.5
	ring@0.17.8
	rusqlite@0.32.1
	rustc_version@0.4.1
	rust-ini@0.21.1
	rustix@0.38.37
	rustls@0.23.14
	rustls-pki-types@1.9.0
	rustls-webpki@0.102.8
	ryu@1.0.18
	same-file@1.0.6
	semver@1.0.23
	serde@1.0.210
	serde_derive@1.0.210
	serde_json@1.0.128
	serde_spanned@0.6.8
	sha2@0.10.8
	shell-escape@0.1.5
	shlex@1.3.0
	slab@0.4.9
	smallvec@1.13.2
	spin@0.9.8
	static_assertions@1.1.0
	subtle@2.6.1
	syn@2.0.79
	system-deps@7.0.3
	tar@0.4.42
	target-lexicon@0.12.16
	temp-dir@0.1.14
	tempfile@3.13.0
	textdistance@1.1.0
	thiserror@1.0.64
	thiserror-impl@1.0.64
	tiny-keccak@2.0.2
	tinyvec@1.8.0
	tinyvec_macros@0.1.1
	toml@0.8.19
	toml_datetime@0.6.8
	toml_edit@0.22.22
	tracing@0.1.40
	tracing-core@0.1.32
	trim-in-place@0.1.7
	typenum@1.17.0
	unicode-bidi@0.3.17
	unicode-ident@1.0.13
	unicode-normalization@0.1.24
	unicode-segmentation@1.12.0
	untrusted@0.9.0
	ureq@2.10.1
	url@2.5.2
	vcpkg@0.2.15
	version_check@0.9.5
	version-compare@0.2.0
	walkdir@2.5.0
	wasi@0.11.0+wasi-snapshot-preview1
	webpki-roots@0.26.6
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
	winnow@0.6.20
	xattr@1.3.1
	zerocopy@0.7.35
	zerocopy-derive@0.7.35
	zeroize@1.8.1
"

PYTHON_COMPAT=( python3_{10..13} )

# from src/sys_info_v2/gatherer/3rdparty/nvtop/nvtop.json
NVTOP_COMMIT=20ea55dbd1eeb4342ff0112fae3ee2a0bfe352ea

inherit cargo gnome2-utils meson python-any-r1 xdg

DESCRIPTION="Monitor your CPU, Memory, Disk, Network and GPU usage."
HOMEPAGE="https://missioncenter.io/"

SRC_URI="
	https://gitlab.com/mission-center-devs/mission-center/-/archive/v${PV}/${PN}-v${PV}.tar.bz2 -> ${P}.tar.bz2
	https://github.com/Syllo/nvtop/archive/${NVTOP_COMMIT}.tar.gz -> nvtop-${NVTOP_COMMIT}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${PN}-v${PV}"
LICENSE="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD
	CC0-1.0 ISC MIT MPL-2.0 Unicode-DFS-2016 GPL-3
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

DEPEND="
	>=dev-libs/appstream-0.16.4
	>=x11-libs/pango-1.51.0
	>=dev-libs/glib-2.79
	>=dev-util/gdbus-codegen-2.79
	dev-libs/wayland
	>=gui-libs/libadwaita-1.6.0
	>=gui-libs/gtk-4.15.0
	gui-libs/egl-gbm
	virtual/udev
	x11-libs/libdrm
"
RDEPEND="
	${DEPEND}
	sys-apps/dmidecode
"
BDEPEND="
	dev-libs/gobject-introspection
	>=dev-build/meson-0.63
	dev-util/blueprint-compiler
	${PYTHON_DEPS}
"

# rust does not use *FLAGS from make.conf, silence portage warning
# update with proper path to binaries this crate installs, omit leading /
QA_FLAGS_IGNORED="
	usr/bin/missioncenter
	usr/bin/missioncenter-gatherer
"

PATCHES=(
	"${FILESDIR}/0.4.5-respect-cargo-home.patch"
)

# meson.eclass default but needs to be set early for src_prepare
BUILD_DIR="${WORKDIR}/${P}-build"

src_prepare() {
	# patch the appstream-util validate command to use --nonet when validating the urls
	sed -i "s/args: \['validate',/args: \['validate', '--nonet',/g" "${S}/data/meson.build" || die

	# setup nvtop subproject
	pushd "${WORKDIR}/nvtop-${NVTOP_COMMIT}" >/dev/null || die
	eapply "${S}/src/sys_info_v2/gatherer/3rdparty/nvtop/patches"
	popd >/dev/null || die
	local nvtop_dest="${BUILD_DIR}/src/sys_info_v2/gatherer/src/$(usex debug debug release)/build/native"
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

pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update
}
