# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	addr2line@0.22.0
	adler32@1.2.0
	adler@1.0.2
	ahash@0.8.11
	aho-corasick@1.1.3
	aligned-vec@0.5.0
	allocator-api2@0.2.18
	android-tzdata@0.1.1
	android_system_properties@0.1.5
	anes@0.1.6
	anstream@0.6.15
	anstyle-parse@0.2.5
	anstyle-query@1.1.1
	anstyle-wincon@3.0.4
	anstyle@1.0.8
	anyhow@1.0.86
	arbitrary@1.3.2
	arg_enum_proc_macro@0.3.4
	arrayref@0.3.8
	arrayvec@0.7.4
	as-raw-xcb-connection@1.0.1
	ash@0.37.3+1.3.251
	assert_fs@1.1.2
	async-broadcast@0.7.1
	async-channel@2.3.1
	async-executor@1.13.0
	async-fs@2.1.2
	async-io@2.3.3
	async-lock@3.4.0
	async-net@2.0.0
	async-process@2.2.3
	async-recursion@1.1.1
	async-signal@0.2.9
	async-task@4.7.1
	async-trait@0.1.81
	atomic-waker@1.1.2
	atomic@0.6.0
	autocfg@1.3.0
	av1-grain@0.2.3
	avif-serialize@0.8.1
	az@1.2.1
	backtrace@0.3.73
	base64@0.13.1
	base64@0.21.7
	base64@0.22.1
	benchmarking@0.4.13
	bit-set@0.5.3
	bit-vec@0.6.3
	bit_field@0.10.2
	bitflags@1.3.2
	bitflags@2.6.0
	bitstream-io@2.5.0
	block-buffer@0.10.4
	block@0.1.6
	blocking@1.6.1
	bstr@1.10.0
	built@0.7.4
	bumpalo@3.16.0
	bytemuck@1.16.1
	bytemuck_derive@1.7.0
	byteorder-lite@0.1.0
	byteorder@1.5.0
	bytes@1.6.1
	cairo-rs@0.18.5
	camino@1.1.7
	cassowary@0.3.0
	cast@0.3.0
	cc@1.1.7
	cfg-expr@0.15.8
	cfg-if@1.0.0
	cfg_aliases@0.1.1
	cfg_aliases@0.2.1
	cgl@0.3.2
	chrono@0.4.38
	ciborium-io@0.2.2
	ciborium-ll@0.2.2
	ciborium@0.2.2
	clap@4.5.11
	clap_builder@4.5.11
	clap_complete@4.5.11
	clap_complete_fig@4.5.2
	clap_derive@4.5.11
	clap_lex@0.7.2
	clipboard-win@2.2.0
	cocoa-foundation@0.1.2
	cocoa@0.25.0
	codespan-reporting@0.11.1
	color_quant@1.1.0
	colorchoice@1.0.2
	colored@2.1.0
	colorgrad@0.6.2
	com-rs@0.2.1
	concurrent-queue@2.5.0
	core-foundation-sys@0.8.6
	core-foundation@0.9.4
	core-graphics-types@0.1.3
	core-graphics@0.23.2
	core-text@20.1.0
	core2@0.4.0
	cpufeatures@0.2.12
	crc32fast@1.4.2
	criterion-plot@0.5.0
	criterion@0.5.1
	crossbeam-channel@0.5.13
	crossbeam-deque@0.8.5
	crossbeam-epoch@0.9.18
	crossbeam-queue@0.3.11
	crossbeam-utils@0.8.20
	crossbeam@0.8.4
	crunchy@0.2.2
	crypto-common@0.1.6
	csscolorparser@0.6.2
	cursor-icon@1.1.0
	d3d12@0.7.0
	darling@0.20.10
	darling_core@0.20.10
	darling_macro@0.20.10
	dary_heap@0.3.6
	data-encoding@2.6.0
	deltae@0.3.2
	deranged@0.3.11
	dhat@0.3.3
	diff@0.1.13
	difflib@0.4.0
	digest@0.10.7
	dirs-next@2.0.0
	dirs-sys-next@0.1.2
	dlib@0.5.2
	dns-lookup@2.0.4
	doc-comment@0.3.3
	downcast-rs@1.2.1
	dwrote@0.11.0
	either@1.13.0
	embed-resource@1.8.0
	emojis@0.6.3
	encoding_rs@0.8.34
	endi@1.1.0
	enum-display-derive@0.1.1
	enumflags2@0.7.10
	enumflags2_derive@0.7.10
	env_filter@0.1.2
	env_logger@0.10.2
	env_logger@0.11.5
	equivalent@1.0.1
	errno@0.3.9
	euclid@0.22.10
	event-listener-strategy@0.5.2
	event-listener@5.3.1
	exr@1.72.0
	fallible-iterator@0.3.0
	fallible-streaming-iterator@0.1.9
	fancy-regex@0.11.0
	fastrand@2.1.0
	fdeflate@0.3.4
	filenamegen@0.2.6
	filetime@0.2.23
	finl_unicode@1.2.0
	fixed@1.28.0
	fixedbitset@0.4.2
	flate2@1.0.30
	float-cmp@0.9.0
	flume@0.11.0
	fnv@1.0.7
	foreign-types-macros@0.2.3
	foreign-types-shared@0.1.1
	foreign-types-shared@0.3.1
	foreign-types@0.3.2
	foreign-types@0.5.0
	form_urlencoded@1.2.1
	fsevent-sys@4.1.0
	futures-channel@0.3.30
	futures-core@0.3.30
	futures-executor@0.3.30
	futures-io@0.3.30
	futures-lite@2.3.0
	futures-macro@0.3.30
	futures-sink@0.3.30
	futures-task@0.3.30
	futures-timer@3.0.3
	futures-util@0.3.30
	futures@0.3.30
	generic-array@0.14.7
	gethostname@0.5.0
	getrandom@0.2.15
	gif@0.13.1
	gimli@0.29.0
	git2@0.18.3
	gl_generator@0.14.0
	glium@0.34.0
	glob@0.3.1
	globset@0.4.14
	globwalk@0.9.1
	glow@0.13.1
	glutin_wgl_sys@0.5.0
	governor@0.5.1
	gpu-alloc-types@0.3.0
	gpu-alloc@0.6.0
	gpu-allocator@0.23.0
	gpu-descriptor-types@0.1.2
	gpu-descriptor@0.2.4
	guillotiere@0.6.2
	h2@0.4.5
	half@2.4.1
	hashbrown@0.12.3
	hashbrown@0.14.5
	hashlink@0.8.4
	hassle-rs@0.10.0
	hdrhistogram@7.5.4
	heck@0.5.0
	hermit-abi@0.3.9
	hermit-abi@0.4.0
	hex@0.4.3
	hexf-parse@0.2.1
	home@0.5.9
	hostname@0.4.0
	http-body-util@0.1.2
	http-body@1.0.1
	http@1.1.0
	http_req@0.11.1
	httparse@1.9.4
	humansize@2.1.3
	humantime@2.1.0
	hyper-rustls@0.27.2
	hyper-tls@0.6.0
	hyper-util@0.1.6
	hyper@1.4.1
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.60
	ident_case@1.0.1
	idna@0.5.0
	ignore@0.4.22
	image-webp@0.1.3
	image@0.25.2
	imgref@1.10.1
	indexmap@1.9.3
	indexmap@2.2.6
	inotify-sys@0.1.5
	inotify@0.9.6
	instant@0.1.13
	interpolate_name@0.2.4
	intrusive-collections@0.9.6
	io-lifetimes@1.0.11
	ioctl-rs@0.1.6
	ipnet@2.9.0
	is-terminal@0.4.12
	is_terminal_polyfill@1.70.1
	itertools@0.10.5
	itertools@0.12.1
	itoa@1.0.11
	jobserver@0.1.32
	jpeg-decoder@0.3.1
	js-sys@0.3.69
	k9@0.12.0
	khronos-egl@6.0.0
	khronos_api@3.1.0
	kqueue-sys@1.0.4
	kqueue@1.0.8
	lab@0.11.0
	lazy_static@1.5.0
	lazycell@1.3.0
	leb128@0.2.5
	lebe@0.5.2
	libc@0.2.155
	libflate@2.1.0
	libflate_lz77@2.1.0
	libfuzzer-sys@0.4.7
	libgit2-sys@0.16.2+1.7.2
	libloading@0.7.4
	libloading@0.8.5
	libm@0.2.8
	libredox@0.1.3
	libsqlite3-sys@0.27.0
	libssh-rs-sys@0.2.4
	libssh-rs@0.3.3
	libssh2-sys@0.3.0
	libz-sys@1.1.18
	line_drawing@0.8.1
	linux-raw-sys@0.3.8
	linux-raw-sys@0.4.14
	lock_api@0.4.12
	log@0.4.22
	loop9@0.1.5
	lru@0.12.3
	lua-src@547.0.0
	luajit-src@210.5.9+04dca79
	mac_address@1.1.7
	mach2@0.4.2
	malloc_buf@0.0.6
	maplit@1.0.2
	maybe-rayon@0.1.1
	memchr@2.7.4
	memmap2@0.8.0
	memmap2@0.9.4
	memmem@0.1.1
	memoffset@0.9.1
	metal@0.27.0
	metrics@0.23.0
	mime@0.3.17
	minimal-lexical@0.2.1
	miniz_oxide@0.7.4
	mintex@0.1.3
	mio@0.8.11
	mio@1.0.1
	mlua-sys@0.6.2
	mlua@0.9.9
	naga@0.14.2
	names@0.12.0
	nanorand@0.7.0
	native-tls@0.2.12
	new_debug_unreachable@1.0.6
	nix@0.28.0
	nix@0.29.0
	no-std-compat@0.4.1
	nom@7.1.3
	nonzero_ext@0.3.0
	noop_proc_macro@0.3.0
	normalize-line-endings@0.3.0
	notify@5.2.0
	ntapi@0.4.1
	nucleo-matcher@0.3.1
	num-bigint@0.4.6
	num-complex@0.4.6
	num-conv@0.1.0
	num-derive@0.4.2
	num-integer@0.1.46
	num-iter@0.1.45
	num-rational@0.4.2
	num-traits@0.2.19
	num@0.4.3
	objc@0.2.7
	objc_exception@0.1.2
	object@0.36.2
	once_cell@1.19.0
	oorandom@11.1.4
	openssl-macros@0.1.1
	openssl-probe@0.1.5
	openssl-src@300.3.1+3.3.1
	openssl-sys@0.9.103
	openssl@0.10.66
	ordered-float@4.2.2
	ordered-stream@0.2.0
	parking@2.2.0
	parking_lot@0.11.2
	parking_lot@0.12.3
	parking_lot_core@0.8.6
	parking_lot_core@0.9.10
	paste@1.0.15
	pem@3.0.4
	percent-encoding@2.3.1
	pest@2.7.11
	pest_derive@2.7.11
	pest_generator@2.7.11
	pest_meta@2.7.11
	phf@0.11.2
	phf_codegen@0.11.2
	phf_generator@0.11.2
	phf_macros@0.11.2
	phf_shared@0.11.2
	pin-project-internal@1.1.5
	pin-project-lite@0.2.14
	pin-project@1.1.5
	pin-utils@0.1.0
	piper@0.2.3
	pkg-config@0.3.30
	plist@1.7.0
	plotters-backend@0.3.6
	plotters-svg@0.3.6
	plotters@0.3.6
	png@0.17.13
	polling@3.7.2
	portable-atomic@1.7.0
	powerfmt@0.2.0
	ppv-lite86@0.2.19
	predicates-core@1.0.8
	predicates-tree@1.0.11
	predicates@3.1.2
	presser@0.3.1
	proc-macro-crate@3.1.0
	proc-macro2@1.0.86
	profiling-procmacros@1.0.15
	profiling@1.0.15
	pure-rust-locales@0.8.1
	qoi@0.4.1
	quick-error@2.0.1
	quick-xml@0.30.0
	quick-xml@0.32.0
	quick-xml@0.34.0
	quote@1.0.36
	rand@0.8.5
	rand_chacha@0.3.1
	rand_core@0.6.4
	range-alloc@0.1.3
	rav1e@0.7.1
	ravif@0.11.9
	raw-window-handle@0.5.2
	rayon-core@1.12.1
	rayon@1.10.0
	rcgen@0.12.1
	redox_syscall@0.2.16
	redox_syscall@0.4.1
	redox_syscall@0.5.3
	redox_users@0.4.5
	regex-automata@0.4.7
	regex-syntax@0.8.4
	regex@1.10.5
	relative-path@1.9.3
	renderdoc-sys@1.1.0
	reqwest@0.12.5
	resize@0.5.5
	rgb@0.8.45
	ring@0.17.8
	rle-decode-fast@1.0.3
	rstest@0.21.0
	rstest_macros@0.21.0
	rusqlite@0.30.0
	rustc-demangle@0.1.24
	rustc-hash@1.1.0
	rustc-hash@2.0.0
	rustc_version@0.4.0
	rustix@0.37.27
	rustix@0.38.34
	rustls-pemfile@2.1.2
	rustls-pki-types@1.7.0
	rustls-webpki@0.102.6
	rustls@0.23.12
	ryu@1.0.18
	same-file@1.0.6
	schannel@0.1.23
	scoped-tls@1.0.1
	scopeguard@1.2.0
	security-framework-sys@2.11.1
	security-framework@2.11.1
	semver@1.0.23
	serde@1.0.204
	serde_derive@1.0.204
	serde_json@1.0.121
	serde_repr@0.1.19
	serde_spanned@0.6.7
	serde_urlencoded@0.7.1
	serde_with@2.3.3
	serde_with_macros@2.3.3
	serde_yaml@0.9.34+deprecated
	serial-core@0.4.0
	serial-unix@0.4.0
	serial-windows@0.4.0
	serial@0.4.0
	sha1@0.10.6
	sha2@0.10.8
	shared_library@0.1.9
	shell-words@1.1.0
	shlex@1.3.0
	signal-hook-registry@1.4.2
	signal-hook@0.3.17
	simd-adler32@0.3.7
	simd_helpers@0.1.0
	siphasher@0.3.11
	slab@0.4.9
	slotmap@1.0.7
	smallvec@1.13.2
	smawk@0.3.2
	smithay-client-toolkit@0.19.2
	smol@2.0.0
	socket2@0.5.7
	spa@0.3.1
	spin@0.9.8
	spirv@0.2.0+1.5.4
	ssh2@0.9.4
	starship-battery@0.8.3
	static_assertions@1.1.0
	strict-num@0.1.1
	strsim@0.11.1
	subtle@2.6.1
	svg_fmt@0.4.3
	syn@1.0.109
	syn@2.0.72
	sync_wrapper@1.0.1
	system-configuration-sys@0.5.0
	system-configuration@0.5.1
	system-deps@6.2.2
	takeable-option@0.5.0
	tar@0.4.41
	target-lexicon@0.12.15
	tempfile@3.10.1
	termcolor@1.4.1
	terminal_size@0.2.6
	terminal_size@0.3.0
	terminfo@0.9.0
	termios@0.2.2
	termios@0.3.3
	termtree@0.4.1
	textwrap@0.16.1
	thiserror-impl@1.0.63
	thiserror@1.0.63
	thousands@0.2.0
	tiff@0.9.1
	time-core@0.1.2
	time-macros@0.2.18
	time@0.3.36
	tiny-skia-path@0.11.4
	tiny-skia@0.11.4
	tinytemplate@1.2.1
	tinyvec@1.8.0
	tinyvec_macros@0.1.1
	tokio-macros@2.4.0
	tokio-native-tls@0.3.1
	tokio-rustls@0.26.0
	tokio-util@0.7.11
	tokio@1.39.2
	toml@0.5.11
	toml@0.8.17
	toml_datetime@0.6.8
	toml_edit@0.21.1
	toml_edit@0.22.18
	tower-layer@0.3.2
	tower-service@0.3.2
	tower@0.4.13
	tracing-attributes@0.1.27
	tracing-core@0.1.32
	tracing@0.1.40
	try-lock@0.2.5
	typenum@1.17.0
	ucd-trie@0.1.6
	uds_windows@1.1.0
	unicase@2.7.0
	unicode-bidi@0.3.15
	unicode-ident@1.0.12
	unicode-linebreak@0.1.5
	unicode-normalization@0.1.23
	unicode-segmentation@1.11.0
	unicode-width@0.1.13
	unicode-xid@0.2.4
	unsafe-libyaml@0.2.11
	untrusted@0.9.0
	uom@0.36.0
	url@2.5.2
	utf8parse@0.2.2
	uuid@1.10.0
	v_frame@0.3.8
	varbincode@0.1.0
	vcpkg@0.2.15
	version-compare@0.2.0
	version_check@0.9.5
	vswhom-sys@0.1.2
	vswhom@0.1.0
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.0+wasi-snapshot-preview1
	wasite@0.1.0
	wasm-bindgen-backend@0.2.92
	wasm-bindgen-futures@0.4.42
	wasm-bindgen-macro-support@0.2.92
	wasm-bindgen-macro@0.2.92
	wasm-bindgen-shared@0.2.92
	wasm-bindgen@0.2.92
	wayland-backend@0.3.6
	wayland-client@0.31.5
	wayland-csd-frame@0.3.0
	wayland-cursor@0.31.5
	wayland-egl@0.32.3
	wayland-protocols-wlr@0.3.3
	wayland-protocols@0.32.3
	wayland-scanner@0.31.4
	wayland-sys@0.31.4
	web-sys@0.3.64
	weezl@0.1.8
	wgpu-core@0.18.1
	wgpu-hal@0.18.1
	wgpu-types@0.18.0
	wgpu@0.18.0
	which@6.0.2
	whoami@1.5.1
	widestring@1.1.0
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.8
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-core@0.51.1
	windows-core@0.52.0
	windows-sys@0.45.0
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-targets@0.42.2
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows@0.33.0
	windows@0.51.1
	windows@0.52.0
	windows_aarch64_gnullvm@0.42.2
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.33.0
	windows_aarch64_msvc@0.42.2
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.33.0
	windows_i686_gnu@0.42.2
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.33.0
	windows_i686_msvc@0.42.2
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.33.0
	windows_x86_64_gnu@0.42.2
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.42.2
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.33.0
	windows_x86_64_msvc@0.42.2
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
	winnow@0.5.40
	winnow@0.6.16
	winreg@0.10.1
	winreg@0.52.0
	winsafe@0.0.19
	wio@0.2.2
	x11@2.21.0
	xattr@1.3.1
	xcb@1.4.0
	xcursor@0.3.6
	xdg-home@1.2.0
	xkbcommon@0.7.0
	xkeysym@0.2.1
	xml-rs@0.8.20
	yasna@0.5.2
	zbus@4.4.0
	zbus_macros@4.4.0
	zbus_names@3.0.0
	zerocopy-derive@0.7.35
	zerocopy@0.7.35
	zeroize@1.8.1
	zstd-safe@5.0.2+zstd.1.5.2
	zstd-sys@2.0.12+zstd.1.5.6
	zstd@0.11.2+zstd.1.5.2
	zune-core@0.4.12
	zune-inflate@0.2.54
	zune-jpeg@0.4.13
	zvariant@4.2.0
	zvariant_derive@4.2.0
	zvariant_utils@2.1.0
"

declare -A GIT_CRATES=(
	[sqlite-cache]='https://github.com/losfair/sqlite-cache;0961b50385ff189bb12742716331c05ed0bf7805;sqlite-cache-%commit%'
	[xcb-imdkit]='https://github.com/wez/xcb-imdkit-rs;358e226573461fe540efb920e2aad740e3c6fab1;xcb-imdkit-rs-%commit%'
)

inherit shell-completion desktop cargo xdg-utils

DESCRIPTION="A GPU-accelerated cross-platform terminal emulator and multiplexer"
HOMEPAGE="https://wezfurlong.org/wezterm/"

if [[ "${PV}" == *_pre0 ]]; then
	COMMIT="56a27e93a9ee50aab50ff4d78308f9b3154b5122"
	MY_PV="$(ver_cut 1)-$(ver_cut 2)-${COMMIT::8}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="
		https://github.com/wez/${PN}/archive/${COMMIT}.tar.gz -> ${MY_P}.tar.gz
		${CARGO_CRATE_URIS}
		"
	S="${WORKDIR}/${PN}-${COMMIT}"
else
	COMMIT=""
	MY_PV="$(ver_cut 1)-$(ver_cut 2)-${COMMIT::8}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="
		https://github.com/wez/${PN}/releases/download/${MY_PV}/${MY_P}-src.tar.gz
		${CARGO_CRATE_URIS}
		"
	S="${WORKDIR}/${MY_P}"
	KEYWORDS="~amd64"
fi

SUBMODULES=(
	"main@deps/freetype/freetype2 https://github.com/wez/freetype2 e4586d960f339cf75e2e0b34aee30a0ed8353c0d"
	"main@deps/freetype/libpng https://github.com/pnggroup/libpng 8439534daa1d3a5705ba92e653eda9251246dd61"
	"main@deps/freetype/zlib https://github.com/madler/zlib cacf7f1d4e3d44d871b605da3b647f07d718623f"
	"main@deps/harfbuzz/harfbuzz https://github.com/harfbuzz/harfbuzz 9c03576c49db6e7207d9bcdfe3abd170a809157f"
	"git-crate@xcb-imdkit/deps/xcb-imdkit https://github.com/fcitx/xcb-imdkit 30e2f16f9a8b0e338e25ce5e3643809a07ad41f0"
)

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD CC0-1.0 ISC
	LGPL-2.1 MIT MPL-2.0 Unicode-DFS-2016 WTFPL-2 ZLIB
"
SLOT="0"
IUSE="wayland"

RESTRICT="test" # tests require network

DEPEND="
	dev-libs/openssl
	wayland? ( dev-libs/wayland )
	media-fonts/jetbrains-mono
	media-fonts/nerd-fonts[nerdfontssymbolsonly]
	media-fonts/noto
	media-fonts/noto-emoji
	media-fonts/roboto
	media-libs/fontconfig
	media-libs/mesa
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon[X,wayland?]
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-wm
	x11-themes/hicolor-icon-theme
	x11-themes/xcursor-themes
	|| (
		>=sys-libs/ncurses-6.4_p20240330
		x11-terms/wezterm-terminfo
	)
	x11-terms/wezterm-shell-integration
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/cmake
	dev-vcs/git
	virtual/pkgconfig
	virtual/rust
"

QA_FLAGS_IGNORED="
	usr/bin/.*
"

submodule_uris() {
	for line in "${SUBMODULES[@]}"; do
		read -r target url commit <<<"${line}" || die

		if [[ "${url}" == https://github.com/* ]]; then
			SRC_URI+=" ${url}/archive/${commit}.tar.gz -> ${url##*/}-${commit::8}.tar.gz"
		elif [[ "${url}" == https://gitlab.com/* ]]; then
			SRC_URI+=" ${url}/-/archive/${commit}/${url##*/}-${commit::8}.tar.gz"
		else
			die
		fi
	done
}

submodule_uris

src_prepare() {
	# copy submodules to where they should go
	for line in "${SUBMODULES[@]}"; do
		read -r target url commit <<< "${line}" || die
		case ${target} in
			main@*)
				dest="${S}/${target##*@}"
				;;
			git-crate@*)
				crate="${target##*@}"
				crate="${crate%%/*}"
				crate_fmt="$(cut -d ";" -f 3 <<< "${GIT_CRATES[${crate}]}" || die)"
				crate_commit="$(cut -d ";" -f 2 <<< "${GIT_CRATES[${crate}]}" || die)"
				if [[ -n "${crate_fmt}" ]]; then
					crate_dir="${crate_fmt//%commit%/${crate_commit}}"
				else
					crate_dir="${crate}-${crate_commit}"
				fi
				dest="${WORKDIR}/${crate_dir}/${target##*"${crate}"/}"
				;;
		esac
		einfo "Moving data for submodule ${target}"
		rmdir "${dest}" || die
		mv "${WORKDIR}/${url##*/}-${commit}/" "${dest}" || die
	done

	echo "${MY_PV}-gentoo" > .tag || die

	default
	eapply_user
}

src_configure() {
	local myfeatures=(
		distro-defaults
		$(usev wayland)
	)
	cargo_src_configure --no-default-features
}

src_install() {
	dobin "$(cargo_target_dir)/wezterm"
	dobin "$(cargo_target_dir)/wezterm-gui"
	dobin "$(cargo_target_dir)/wezterm-mux-server"
	dobin "$(cargo_target_dir)/strip-ansi-escapes"

	insinto /usr/share/icons/hicolor/128x128/apps
	newins assets/icon/terminal.png org.wezfurlong.wezterm.png

	newmenu assets/wezterm.desktop org.wezfurlong.wezterm.desktop

	insinto /usr/share/metainfo
	newins assets/wezterm.appdata.xml org.wezfurlong.wezterm.appdata.xml

	insinto /usr/share/nautilus-python/extensions
	newins assets/wezterm-nautilus.py "${PN}.py"

	newbashcomp assets/shell-completion/bash "${PN}"
	newzshcomp assets/shell-completion/zsh "_${PN}"
	newfishcomp assets/shell-completion/fish "${PN}.fish"
}

pkg_postinst() {
	xdg_icon_cache_update
	einfo "It may be necessary to configure wezterm to use a cursor theme, see:"
	einfo "https://wezfurlong.org/wezterm/faq.html?highlight=xcursor_theme#i-use-x11-or-wayland-and-my-mouse-cursor-theme-doesnt-seem-to-work"
	einfo "It may be necessary to set the environment variable XCURSOR_PATH"
	einfo "to the directory containing the cursor icons, for example"
	einfo 'export XCURSOR_PATH="/usr/share/cursors/xorg-x11/"'
	einfo "before starting the wayland or X11 window compositor to avoid the error:"
	einfo "ERROR  window::os::wayland::frame > Unable to set cursor to left_ptr: cursor not found"
	einfo "For example, in the file ~/.wezterm.lua:"
	einfo "return {"
	einfo '  xcursor_theme = "whiteglass"'
	einfo "}"
}

pkg_postrm() {
	xdg_icon_cache_update
}
