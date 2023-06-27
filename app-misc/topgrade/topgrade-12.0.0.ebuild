# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	addr2line@0.19.0
	adler@1.0.2
	ahash@0.7.6
	aho-corasick@0.7.20
	android-tzdata@0.1.1
	android_system_properties@0.1.5
	async-broadcast@0.5.1
	async-channel@1.8.0
	async-executor@1.5.1
	async-fs@1.6.0
	async-io@1.13.0
	async-lock@2.7.0
	async-process@1.7.0
	async-recursion@1.0.4
	async-task@4.4.0
	async-trait@0.1.68
	atomic-waker@1.1.1
	atty@0.2.14
	autocfg@1.1.0
	backtrace@0.3.67
	base64@0.21.2
	bitflags@1.3.2
	block-buffer@0.10.4
	block@0.1.6
	blocking@1.3.1
	bumpalo@3.13.0
	byteorder@1.4.3
	bytes@1.4.0
	cc@1.0.79
	cfg-if@1.0.0
	chrono@0.4.26
	clap@3.1.18
	clap_complete@3.1.4
	clap_derive@3.1.18
	clap_lex@0.2.4
	clap_mangen@0.1.7
	color-eyre@0.6.2
	color-spantrace@0.2.0
	concurrent-queue@2.2.0
	console@0.15.7
	core-foundation-sys@0.8.4
	cpufeatures@0.2.8
	crc32fast@1.3.2
	crossbeam-utils@0.8.16
	crypto-common@0.1.6
	derivative@2.2.0
	digest@0.10.7
	dirs-next@2.0.0
	dirs-sys-next@0.1.2
	dirs-sys@0.3.7
	dirs@4.0.0
	dlv-list@0.3.0
	either@1.8.1
	encode_unicode@0.3.6
	encoding_rs@0.8.32
	enumflags2@0.7.7
	enumflags2_derive@0.7.7
	errno-dragonfly@0.1.2
	errno@0.3.1
	etcetera@0.8.0
	event-listener@2.5.3
	eyre@0.6.8
	fastrand@1.9.0
	filetime@0.2.21
	flate2@1.0.26
	fnv@1.0.7
	form_urlencoded@1.2.0
	futures-channel@0.3.28
	futures-core@0.3.28
	futures-executor@0.3.28
	futures-io@0.3.28
	futures-lite@1.13.0
	futures-macro@0.3.28
	futures-sink@0.3.28
	futures-task@0.3.28
	futures-util@0.3.28
	futures@0.3.28
	generic-array@0.14.7
	getrandom@0.2.10
	gimli@0.27.3
	glob@0.3.1
	h2@0.3.20
	hashbrown@0.12.3
	heck@0.4.1
	hermit-abi@0.1.19
	hermit-abi@0.2.6
	hermit-abi@0.3.1
	hex@0.4.3
	home@0.5.5
	http-body@0.4.5
	http@0.2.9
	httparse@1.8.0
	httpdate@1.0.2
	hyper-rustls@0.24.0
	hyper@0.14.27
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.57
	idna@0.4.0
	indenter@0.3.3
	indexmap@1.9.3
	indicatif@0.16.2
	instant@0.1.12
	io-lifetimes@1.0.11
	ipnet@2.7.2
	itoa@1.0.6
	js-sys@0.3.64
	lazy_static@1.4.0
	libc@0.2.147
	linux-raw-sys@0.3.8
	log@0.4.19
	mac-notification-sys@0.5.6
	malloc_buf@0.0.6
	matchers@0.1.0
	memchr@2.5.0
	memoffset@0.6.5
	memoffset@0.7.1
	merge@0.1.0
	merge_derive@0.1.0
	mime@0.3.17
	miniz_oxide@0.6.2
	miniz_oxide@0.7.1
	mio@0.8.8
	nix@0.24.3
	nix@0.26.2
	notify-rust@4.8.0
	nu-ansi-term@0.46.0
	num-traits@0.2.15
	num_cpus@1.15.0
	number_prefix@0.4.0
	objc-foundation@0.1.1
	objc@0.2.7
	objc_id@0.1.1
	object@0.30.4
	once_cell@1.17.2
	ordered-multimap@0.4.3
	ordered-stream@0.2.0
	os_str_bytes@6.5.1
	overload@0.1.1
	owo-colors@3.5.0
	parking@2.1.0
	parselnk@0.1.1
	percent-encoding@2.3.0
	pin-project-lite@0.2.9
	pin-utils@0.1.0
	polling@2.8.0
	ppv-lite86@0.2.17
	proc-macro-crate@1.3.1
	proc-macro-error-attr@1.0.4
	proc-macro-error@1.0.4
	proc-macro2@1.0.63
	quick-xml@0.22.0
	quick-xml@0.23.1
	quote@1.0.28
	rand@0.8.5
	rand_chacha@0.3.1
	rand_core@0.6.4
	redox_syscall@0.2.16
	redox_users@0.4.3
	regex-automata@0.1.10
	regex-split@0.1.0
	regex-syntax@0.6.29
	regex@1.7.3
	remove_dir_all@0.5.3
	reqwest@0.11.18
	ring@0.16.20
	roff@0.2.1
	rust-ini@0.18.0
	rustc-demangle@0.1.23
	rustix@0.37.20
	rustls-pemfile@1.0.2
	rustls-webpki@0.100.1
	rustls@0.21.2
	rustversion@1.0.12
	ryu@1.0.13
	same-file@1.0.6
	sct@0.7.0
	self_update@0.30.0
	semver@1.0.17
	serde@1.0.164
	serde_derive@1.0.164
	serde_json@1.0.99
	serde_repr@0.1.12
	serde_urlencoded@0.7.1
	sha1@0.10.5
	sharded-slab@0.1.4
	shell-words@1.1.0
	shellexpand@2.1.2
	signal-hook-registry@1.4.1
	signal-hook@0.3.15
	slab@0.4.8
	smallvec@1.10.0
	socket2@0.4.9
	spin@0.5.2
	static_assertions@1.1.0
	strsim@0.10.0
	strum@0.24.1
	strum_macros@0.24.3
	syn@1.0.109
	syn@2.0.22
	tar@0.4.38
	tauri-winrt-notification@0.1.1
	tempfile@3.2.0
	termcolor@1.2.0
	textwrap@0.15.2
	thiserror-impl@1.0.40
	thiserror@1.0.40
	thread_local@1.1.7
	time-core@0.1.1
	time-macros@0.2.9
	time@0.1.45
	time@0.3.22
	tinyvec@1.6.0
	tinyvec_macros@0.1.1
	tokio-rustls@0.24.1
	tokio-util@0.7.2
	tokio@1.18.6
	toml@0.5.11
	toml_datetime@0.6.3
	toml_edit@0.19.8
	tower-service@0.3.2
	tracing-attributes@0.1.26
	tracing-core@0.1.31
	tracing-error@0.2.0
	tracing-log@0.1.3
	tracing-subscriber@0.3.17
	tracing@0.1.37
	try-lock@0.2.4
	typenum@1.16.0
	uds_windows@1.0.2
	unicode-bidi@0.3.13
	unicode-ident@1.0.9
	unicode-normalization@0.1.22
	unicode-width@0.1.10
	untrusted@0.7.1
	url@2.4.0
	valuable@0.1.0
	version_check@0.9.4
	waker-fn@1.1.0
	walkdir@2.3.3
	want@0.3.1
	wasi@0.10.0+wasi-snapshot-preview1
	wasi@0.11.0+wasi-snapshot-preview1
	wasm-bindgen-backend@0.2.87
	wasm-bindgen-futures@0.4.37
	wasm-bindgen-macro-support@0.2.87
	wasm-bindgen-macro@0.2.87
	wasm-bindgen-shared@0.2.87
	wasm-bindgen@0.2.87
	web-sys@0.3.64
	webpki-roots@0.22.6
	webpki@0.22.0
	which@4.1.0
	widestring@0.4.3
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.5
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-sys@0.45.0
	windows-sys@0.48.0
	windows-targets@0.42.2
	windows-targets@0.48.0
	windows@0.39.0
	windows@0.48.0
	windows_aarch64_gnullvm@0.42.2
	windows_aarch64_gnullvm@0.48.0
	windows_aarch64_msvc@0.39.0
	windows_aarch64_msvc@0.42.2
	windows_aarch64_msvc@0.48.0
	windows_i686_gnu@0.39.0
	windows_i686_gnu@0.42.2
	windows_i686_gnu@0.48.0
	windows_i686_msvc@0.39.0
	windows_i686_msvc@0.42.2
	windows_i686_msvc@0.48.0
	windows_x86_64_gnu@0.39.0
	windows_x86_64_gnu@0.42.2
	windows_x86_64_gnu@0.48.0
	windows_x86_64_gnullvm@0.42.2
	windows_x86_64_gnullvm@0.48.0
	windows_x86_64_msvc@0.39.0
	windows_x86_64_msvc@0.42.2
	windows_x86_64_msvc@0.48.0
	winnow@0.4.1
	winreg@0.10.1
	xattr@0.2.3
	xdg-home@1.0.0
	zbus@3.13.1
	zbus_macros@3.13.1
	zbus_names@2.5.1
	zip@0.6.6
	zvariant@3.14.0
	zvariant_derive@3.14.0
	zvariant_utils@1.0.1
"

inherit cargo bash-completion-r1

DESCRIPTION="Upgrade all the things"
HOMEPAGE="https://github.com/topgrade-rs/topgrade"
SRC_URI="
	${CARGO_CRATE_URIS}
	https://github.com/topgrade-rs/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

src_install() {
	cargo_src_install

	# Shell completions
	mkdir -p ${S}/completions

	# bash
	${ED}/usr/bin/topgrade --gen-completion bash > ${S}/completions/${PN}.bash
	newbashcomp ${S}/completions/${PN}.bash ${PN}

	# zsh
	${ED}/usr/bin/topgrade --gen-completion zsh > ${S}/completions/_${PN}
	insinto /usr/share/zsh/site-functions
	doins ${S}/completions/_${PN}

	# fish
	${ED}/usr/bin/topgrade --gen-completion fish > ${S}/completions/${PN}.fish
	insinto /usr/share/fish/vendor_completions.d
	doins ${S}/completions/${PN}.fish

	# manpage
	${ED}/usr/bin/topgrade --gen-manpage > ${S}/completions/${PN}.1
	doman ${S}/completions/${PN}.1
}
