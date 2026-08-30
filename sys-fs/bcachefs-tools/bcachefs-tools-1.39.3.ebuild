# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

CRATES="
	aho-corasick@1.1.4
	android_system_properties@0.1.5
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.103
	arbitrary@1.4.2
	ascii@1.1.0
	autocfg@1.5.1
	bindgen@0.72.1
	bitfield@0.14.0
	bitflags@1.3.2
	bitflags@2.13.0
	bumpalo@3.19.1
	bytemuck@1.25.0
	bytemuck_derive@1.10.2
	cc@1.2.66
	cexpr@0.6.0
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	chrono@0.4.45
	chunked_transfer@1.5.0
	clang-sys@1.8.1
	clap@4.6.1
	clap_builder@4.6.0
	clap_complete@4.5.33
	clap_derive@4.6.1
	clap_lex@1.1.0
	clipboard-win@5.4.1
	colorchoice@1.0.5
	core-foundation-sys@0.8.7
	crossterm@0.29.0
	derive_arbitrary@1.4.2
	dissimilar@1.0.11
	document-features@0.2.12
	either@1.16.0
	endian-type@0.1.2
	env_logger@0.10.2
	equivalent@1.0.2
	errno@0.3.14
	error-code@3.3.2
	fd-lock@4.0.4
	fiemap@0.2.0
	find-msvc-tools@0.1.9
	fuser@0.17.0
	getrandom@0.4.3
	glob@0.3.3
	hashbrown@0.17.1
	heck@0.5.0
	hermit-abi@0.3.9
	home@0.5.11
	httpdate@1.0.3
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	indexmap@2.14.0
	io-lifetimes@1.0.11
	is_terminal_polyfill@1.70.2
	itertools@0.12.1
	itoa@1.0.18
	js-sys@0.3.85
	libc@0.2.189
	libloading@0.8.5
	libudev-sys@0.1.4
	linux-raw-sys@0.12.1
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.33
	memchr@2.8.3
	memoffset@0.9.1
	minimal-lexical@0.2.1
	mio@1.2.1
	nibble_vec@0.1.0
	nix@0.30.1
	nom@7.1.3
	num-traits@0.2.19
	num_enum@0.7.5
	num_enum_derive@0.7.5
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	owo-colors@4.1.0
	page_size@0.6.0
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste-test-suite@0.0.0
	paste@1.0.15
	pkg-config@0.3.33
	prettyplease@0.2.37
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	quote@1.0.46
	r-efi@6.0.0
	radix_trie@0.2.1
	redox_syscall@0.5.18
	ref-cast-impl@1.0.25
	ref-cast@1.0.25
	regex-automata@0.4.14
	regex-syntax@0.8.11
	regex@1.12.4
	rustc-demangle@0.1.27
	rustc-hash@2.1.2
	rustix@1.1.4
	rustversion@1.0.22
	rustyline@17.0.2
	scopeguard@1.2.0
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	serde_spanned@1.1.1
	serde_test@1.0.177
	shlex@1.3.0
	shlex@2.0.1
	signal-hook-mio@0.2.5
	signal-hook-registry@1.4.8
	signal-hook@0.3.18
	smallvec@1.15.2
	strsim@0.11.1
	strum@0.26.3
	strum_macros@0.26.4
	syn@2.0.118
	target-triple@1.0.0
	termcolor@1.4.1
	terminal_size@0.4.4
	tiny_http@0.12.0
	toml@1.0.6+spec-1.1.0
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.10+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	toml_writer@1.1.1+spec-1.1.0
	trybuild@1.0.116
	udev@0.9.3
	unicode-ident@1.0.24
	unicode-segmentation@1.13.3
	unicode-width@0.2.2
	utf8parse@0.2.2
	uuid@1.23.4
	wasi@0.11.1+wasi-snapshot-preview1
	wasm-bindgen-macro-support@0.2.108
	wasm-bindgen-macro@0.2.108
	wasm-bindgen-shared@0.2.108
	wasm-bindgen@0.2.108
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.48.0
	windows-sys@0.59.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.1
	winnow@0.7.15
	winnow@1.0.3
	zerocopy-derive@0.8.53
	zerocopy@0.8.53
	zeroize@1.9.0
	zeroize_derive@1.5.0
	zmij@1.0.21
"

LLVM_COMPAT=( {19..22} )
MODULES_INITRAMFS_IUSE=+initramfs
MODULES_KERNEL_MIN=6.16
MODULES_OPTIONAL_IUSE=+modules
PYTHON_COMPAT=( python3_{12..15} )
RUST_MIN_VER="1.85.0"
RUST_NEEDS_LLVM=1
VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/kentoverstreet.asc

# for _pre* snapshots
# git -c safe.directory=$PWD -c core.abbrev=12 describe
# ("v${PV}" if unset)
#BCH_VERSION=

inherit cargo flag-o-matic linux-mod-r1 llvm-r1 multiprocessing python-any-r1
inherit shell-completion toolchain-funcs unpacker verify-sig udev systemd

DESCRIPTION="Tools for bcachefs"
HOMEPAGE="https://bcachefs.org/"
if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://evilpiepirate.org/git/bcachefs-tools.git"
else
	if [[ ${PV} == *_pre* ]]; then
		# fetch via BCH_VERSION as a rough QA check (should always match COMMIT)
		SRC_URI="
			https://github.com/koverstreet/bcachefs-tools/archive/${BCH_VERSION}.tar.gz
				-> ${PN}-${BCH_VERSION}.tar.gz
			${CARGO_CRATE_URIS}
		"
	else
		SRC_URI="
			https://evilpiepirate.org/bcachefs-tools/${P}.tar.zst
			${CARGO_CRATE_URIS}
		"
		SRC_URI+=" verify-sig? ( https://evilpiepirate.org/bcachefs-tools/bcachefs-tools-${PV}.tar.sign )"
		KEYWORDS="~amd64 ~arm64"
	fi
fi

LICENSE="GPL-2"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD-2 BSD ISC MIT Unicode-3.0"
SLOT="0"
IUSE="debug llvm-libunwind verify-sig"

# manual testing for now:
# fallocate -l 10G /tmp/bcfs.img
# loopdev=$(losetup --find --show /tmp/bcfs.img)
# bcachefs format $loopdev
# mkdir -p /tmp/bcfs-mount
# mount -t bcachefs $loopdev /tmp/bcfs-mount
# touch /tmp/bcfs-mount/foo
RESTRICT="test"

DEPEND="
	app-arch/lz4:=
	app-arch/zstd:=
	dev-libs/libaio
	dev-libs/libsodium:=
	dev-libs/userspace-rcu:=
	sys-apps/keyutils:=
	sys-apps/util-linux
	virtual/zlib:=
	virtual/udev
	llvm-libunwind? ( llvm-runtimes/libunwind:= )
	!llvm-libunwind? ( sys-libs/libunwind:= )
"

# bcachefs-kmod in ::guru provided USE=modules for previous tools versions.
RDEPEND="
	${DEPEND}
	modules? ( !sys-fs/bcachefs-kmod )
"

# Clang is required for bindgen
# shellcheck disable=SC2016 # don't want expansion
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep '
		dev-python/docutils[${PYTHON_USEDEP}]
	')
	$(unpacker_src_uri_depends)
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
	')
	elibc_musl? ( >=sys-libs/musl-1.2.5 )
	virtual/pkgconfig
	modules? ( >=sys-kernel/linux-headers-${MODULES_KERNEL_MIN}.0 )
	verify-sig? ( >=sec-keys/openpgp-keys-kentoverstreet-20241012 )
	${RUST_DEPEND}
"

QA_FLAGS_IGNORED="sbin/bcachefs"

python_check_deps() {
	python_has_version "dev-python/docutils[${PYTHON_USEDEP}]"
}

pkg_setup() {
	# early llvm_prepend_path
	# to keep C and Rust synced
	if [[ ${MERGE_TYPE} != binary ]]; then
		llvm_prepend_path "${LLVM_SLOT}"
	fi

	llvm-r1_pkg_setup
	python-any-r1_pkg_setup
	rust_pkg_setup
	if use modules; then
		# grep -r 'depends on\|select ' ${S}/fs/Kconfig | grep -v '^#'
		local CONFIG_CHECK="
			BLOCK
			EXPORTFS
			CRC32
			CRC64
			FS_POSIX_ACL
			LZ4_COMPRESS
			LZ4_DECOMPRESS
			LZ4HC_COMPRESS
			ZLIB_DEFLATE
			ZLIB_INFLATE
			ZSTD_COMPRESS
			ZSTD_DECOMPRESS
			CRYPTO_LIB_SHA256
			CRYPTO_LIB_CHACHA
			CRYPTO_LIB_POLY1305
			KEYS
			RAID6_PQ
			XOR_BLOCKS
			XXHASH
			SYMBOLIC_ERRNAME
		"
		use debug && CONFIG_CHECK+="
			DEBUG_INFO
			FRAME_POINTER
			!DEBUG_INFO_REDUCED
		"
		[[ -z "${IGNORE_EXISTING_KMOD}" ]] && CONFIG_CHECK+="
		    !BCACHEFS_FS
		"
		linux-mod-r1_pkg_setup
	fi
}

src_unpack() {
	case "${PV}" in
		9999)
			if use verify-sig; then
				ewarn "USE=verify-sig is ignored for live package"
			fi

			git-r3_src_unpack
			S="${S}/rust-src" cargo_live_src_unpack
			;;
		*_pre*)
			# Snapshots come from GitHub and thus aren't signed
			if use verify-sig; then
				ewarn "USE=verify-sig is ignored for prerelease snapshots"
			fi

			unpacker "${PN}-${BCH_VERSION}.tar.gz"
			cargo_src_unpack

			# the archive name is based on the full commit,
			# not the git describe name
			local -a s=( "${WORKDIR}/${PN}-${BCH_VERSION#*-g}"* )
			(( ${#s[*]} == 1 )) || die "Could not get S from BCH_VERSION"
			S="${s[0]}"
			;;
		*)
			# Upstream signs the uncompressed tarball
			if use verify-sig; then
				einfo "Unpacking ${P}.tar.zst ..."
				verify-sig_verify_detached - "${DISTDIR}/${P}.tar.sign" \
					< <(zstd -fdc "${DISTDIR}/${P}.tar.zst" | tee >(tar -xf -))
				assert "Unpack failed"
			fi

			unpacker "${P}.tar.zst"
			cargo_src_unpack
			;;
	esac
}

src_prepare() {
	default
	tc-export CC

	sed \
		-e '/^CFLAGS/s:-O2::' \
		-e '/^CFLAGS/s:-g::' \
		-i Makefile || die
	append-lfs-flags

	# llvm-runtimes/libunwind doesn't provide pkgconfig files
	# so we need to handle it ourself...
	if use llvm-libunwind; then
		sed -E \
			-e '/^PKGCONFIG_LIBS/s/(".*) libunwind(.*")/\1\2/' \
			-i Makefile || die
		export EXTRA_LDLIBS="-lunwind"
	fi

	# there currently are no prebuilt Gentoo modules
	# (and not sure if there ever will be as there is no "standard kernel" besides maybe gentoo-kernel-bin)
	# but we'll disable the automagic module fetch anyways just in case
	cat > fs/scripts/fetch-module.sh <<-EOF || die "Could not disable fetch-module.sh"
	#!/bin/sh
	echo "fetch-module.sh disabled to force source build" 1>&2
	exit 1
	EOF

	# generate version.h
	echo "${BCH_VERSION:-"v${PV}"}" > .version || die
	emake generate_version
}

src_configure() {
	cargo_src_configure
	use modules && emake DESTDIR="${WORKDIR}" DKMSDIR="/module" install_dkms
}

src_compile() {
	export BUILD_VERBOSE=1
	local modlist=( "bcachefs=:../module:../module/src/fs/bcachefs" )
	local modargs=( KDIR="${KV_OUT_DIR}" )

	# Makefile calls `cargo` directly, so make sure we set our rustflags (etc)
	cargo_env emake "-j$(get_makeopts_jobs)" bcachefs || die
	use modules && linux-mod-r1_src_compile

	(
		# shellcheck disable=SC2155
		export PATH="$(cargo_target_dir):${PATH}"

		for shell in bash fish zsh; do
			bcachefs completions "${shell}" > "${shell}.completion" || die
		done
	)

	local template
	for template in bcachefs-wait-devices@.service.in udev/64-bcachefs.rules.in; do
		sed -e 's|@sbindir@|/sbin|g' "${template}" > "${template%.in}" || die
	done
}

src_install() {
	# main tools binary
	into /
	dosbin "$(cargo_target_dir)/bcachefs"

	# module
	use modules && linux-mod-r1_src_install

	# kernel mount helpers
	dosym bcachefs /sbin/fsck.bcachefs
	dosym bcachefs /sbin/mkfs.bcachefs
	dosym bcachefs /sbin/mount.bcachefs

	# fuse mount helpers
	dosym bcachefs /sbin/fsck.fuse.bcachefs
	dosym bcachefs /sbin/mkfs.fuse.bcachefs
	dosym bcachefs /sbin/mount.fuse.bcachefs

	# shell completions
	newbashcomp bash.completion bcachefs
	newfishcomp fish.completion bcachefs.fish
	newzshcomp zsh.completion _bcachefs

	# docs
	doman bcachefs.8

	# udev rules
	udev_dorules udev/64-bcachefs.rules
	insinto /usr/lib/dracut/dracut.conf.d
	# linux-mod-r1_src_install installs 10-${PN}.conf
	newins - "11-${PN}.conf" <<<"install_items+=\" $(get_udevdir)/64-bcachefs.rules \""

	# systemd units/generators
	dosym -r /sbin/bcachefs "$(systemd_get_systemgeneratordir)/bcachefs-mount-generator"
	systemd_dounit bcachefs-wait-devices@.service
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
