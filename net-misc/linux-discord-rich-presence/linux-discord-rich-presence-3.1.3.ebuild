# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	atty-0.2.14
	autocfg-1.1.0
	bitflags-1.3.2
	bytes-1.4.0
	cfg-if-1.0.0
	clap-3.2.23
	clap_derive-3.2.18
	clap_lex-0.2.4
	crossbeam-channel-0.5.6
	crossbeam-utils-0.8.14
	discord-rich-presence-0.2.3
	filetime-0.2.19
	fsevent-sys-4.1.0
	getrandom-0.2.8
	hashbrown-0.12.3
	heck-0.4.1
	hermit-abi-0.1.19
	indexmap-1.9.2
	inotify-0.9.6
	inotify-sys-0.1.5
	is_executable-1.0.1
	itoa-1.0.5
	kqueue-1.0.7
	kqueue-sys-1.0.3
	lazy_static-1.4.0
	libc-0.2.139
	log-0.4.17
	memchr-2.5.0
	mio-0.8.5
	notify-5.1.0
	num_threads-0.1.6
	once_cell-1.17.0
	os_str_bytes-6.4.1
	pin-project-lite-0.2.9
	proc-macro-error-1.0.4
	proc-macro-error-attr-1.0.4
	proc-macro2-1.0.51
	quote-1.0.23
	redox_syscall-0.2.16
	ryu-1.0.12
	same-file-1.0.6
	serde-1.0.152
	serde_derive-1.0.152
	serde_json-1.0.92
	signal-hook-registry-1.4.0
	simplelog-0.12.0
	strsim-0.10.0
	syn-1.0.107
	termcolor-1.1.3
	textwrap-0.16.0
	thiserror-1.0.38
	thiserror-impl-1.0.38
	time-0.3.17
	time-core-0.1.0
	time-macros-0.2.6
	tokio-1.25.0
	tokio-macros-1.8.2
	unicode-ident-1.0.6
	uuid-0.8.2
	version_check-0.9.4
	walkdir-2.3.2
	wasi-0.11.0+wasi-snapshot-preview1
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-util-0.1.5
	winapi-x86_64-pc-windows-gnu-0.4.0
	windows-sys-0.42.0
	windows_aarch64_gnullvm-0.42.1
	windows_aarch64_msvc-0.42.1
	windows_i686_gnu-0.42.1
	windows_i686_msvc-0.42.1
	windows_x86_64_gnu-0.42.1
	windows_x86_64_gnullvm-0.42.1
	windows_x86_64_msvc-0.42.1
"

inherit desktop cargo

DESCRIPTION="Customizable Discord Rich Presence client for Linux"
HOMEPAGE="https://github.com/trickybestia/linux-discord-rich-presence"
SRC_URI="
	https://github.com/trickybestia/linux-discord-rich-presence/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris)
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

# rust does not use *FLAGS from make.conf, silence portage warning
# update with proper path to binaries this crate installs, omit leading /
QA_FLAGS_IGNORED="usr/bin/${PN}"

src_install() {
	cargo_src_install

	# rely on $PATH instead of location
	sed -i -e 's|/usr/bin/||g' ${S}/doc/${PN}-desktop-wrapper || die "sed failed"
	exeinto /usr/bin
	doexe ${S}/doc/${PN}-desktop-wrapper

	for desktopfile in ${S}/doc/${PN}{,-minimized}.desktop; do
		# rely on $PATH instead of location
		sed -i -e 's|/usr/bin/||g' -e '/^Path=/d' ${desktopfile} || die "sed failed"
		domenu ${desktopfile}
	done
}

pkg_postinst() {
	elog "For configuration check upstream documentation at"
	elog "https://github.com/trickybestia/linux-discord-rich-presence/tree/main/doc"
}
