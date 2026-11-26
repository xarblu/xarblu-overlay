# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

CRATES="
	addr2line@0.25.1
	adler2@2.0.1
	aho-corasick@1.1.4
	android_system_properties@0.1.5
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.103
	ascii@1.1.0
	autocfg@1.5.1
	backtrace@0.3.76
	base64@0.13.1
	bindgen@0.66.1
	bindgen@0.72.1
	bitfield-struct@0.13.0
	bitflags@2.13.0
	block-buffer@0.12.1
	bumpalo@3.19.1
	cc@1.2.66
	cexpr@0.6.0
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	chacha20@0.10.2
	chrono@0.4.45
	chunked_transfer@1.5.0
	cipher@0.5.2
	clang-sys@1.8.1
	clap@4.6.1
	clap_builder@4.6.0
	clap_complete@4.5.33
	clap_derive@4.6.1
	clap_lex@1.1.0
	clipboard-win@5.4.1
	cmov@0.5.4
	colorchoice@1.0.5
	core-foundation-sys@0.8.7
	cpufeatures@0.3.1
	crc32c@0.6.9
	crossterm@0.29.0
	crypto-common@0.2.2
	ctutils@0.4.2
	digest@0.11.3
	document-features@0.2.12
	either@1.16.0
	embed-doc-image@0.1.4
	endian-type@0.2.0
	enum-iterator-derive@1.5.0
	enum-iterator@2.3.0
	env_logger@0.10.2
	equivalent@1.0.2
	errno@0.3.14
	error-code@3.3.2
	find-msvc-tools@0.1.9
	getrandom@0.4.3
	gimli@0.32.3
	glob@0.3.3
	hashbrown@0.17.1
	heck@0.5.0
	hmac@0.13.0
	home@0.5.12
	httpdate@1.0.3
	hybrid-array@0.4.15
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	indexmap@2.14.0
	inout@0.2.6
	io-uring@0.7.16
	is_terminal_polyfill@1.70.2
	itertools@0.12.1
	itoa@1.0.18
	js-sys@0.3.85
	lazy_static@1.5.1
	lazycell@1.3.0
	libc@0.2.189
	libloading@0.8.5
	linux-keyutils@0.2.5
	linux-raw-sys@0.12.1
	linux-raw-sys@0.4.15
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.33
	memchr@2.8.3
	memoffset@0.9.1
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	mio@1.2.1
	nibble_vec@0.1.0
	nix@0.30.1
	nix@0.31.3
	nom@7.1.3
	num_enum@0.7.5
	num_enum_derive@0.7.5
	object@0.37.3
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	owo-colors@4.1.0
	page_size@0.6.0
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	pbkdf2@0.13.0
	peeking_take_while@0.1.2
	pkg-config@0.3.33
	poly1305@0.9.1
	prettyplease@0.2.37
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	quote@1.0.46
	r-efi@6.0.0
	radix_trie@0.3.0
	redox_syscall@0.5.18
	ref-cast-impl@1.0.25
	ref-cast@1.0.25
	regex-automata@0.4.14
	regex-syntax@0.8.11
	regex@1.12.4
	rsblkid-sys@0.2.2
	rsblkid@0.4.1
	rustc-demangle@0.1.27
	rustc-hash@1.1.0
	rustc-hash@2.1.2
	rustc_version@0.4.1
	rustix@0.38.44
	rustix@1.1.4
	rustversion@1.0.22
	rustyline@18.0.1
	salsa20@0.11.0
	scopeguard@1.2.0
	scrypt@0.12.0
	semver@1.0.28
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	sha2@0.11.0
	shlex@1.3.0
	shlex@2.0.1
	signal-hook-mio@0.2.5
	signal-hook-registry@1.4.8
	signal-hook@0.3.18
	smallvec@1.15.2
	stable_deref_trait@1.2.1
	strsim@0.11.1
	syn@1.0.109
	syn@2.0.118
	terminal_size@0.4.4
	thiserror-impl@1.0.69
	thiserror@1.0.69
	tiny_http@0.12.0
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.10+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	twox-hash@2.1.5
	typed-builder-macro@0.20.1
	typed-builder@0.20.1
	typenum@1.20.1
	unicode-ident@1.0.24
	unicode-segmentation@1.13.3
	unicode-width@0.2.2
	universal-hash@0.6.1
	utf8parse@0.2.2
	uuid@1.23.4
	wasi@0.11.1+wasi-snapshot-preview1
	wasm-bindgen-macro-support@0.2.108
	wasm-bindgen-macro@0.2.108
	wasm-bindgen-shared@0.2.108
	wasm-bindgen@0.2.108
	which@4.4.2
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.59.0
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
	winnow@1.0.3
	yoke@0.8.4
	zerocopy-derive@0.8.53
	zerocopy@0.8.53
	zeroize@1.9.0
	zeroize_derive@1.5.0
	zmij@1.0.21
"

declare -A GIT_CRATES=(
	[fuser]='https://github.com/koverstreet/fuser;88195892644d78da0f90c84ad52fbe916cbd1886;fuser-%commit%'
	[g2gen]='https://github.com/koverstreet/g2p;822e816429736c209a24f6b376c2672f4625a671;g2p-%commit%/g2gen'
	[g2p-kernels]='https://github.com/koverstreet/g2p;822e816429736c209a24f6b376c2672f4625a671;g2p-%commit%/g2p-kernels'
	[g2p]='https://github.com/koverstreet/g2p;822e816429736c209a24f6b376c2672f4625a671;g2p-%commit%/g2p'
	[g2poly]='https://github.com/koverstreet/g2p;822e816429736c209a24f6b376c2672f4625a671;g2p-%commit%/g2poly'
	[nestify]='https://github.com/koverstreet/nestify;49f93fbf42c10d7bffe502f0e51287a0a4e767ad;nestify-%commit%'
	[num-traits]='https://github.com/koverstreet/num-traits;34eeca40d5e25d564244cb43c0d32753422d3520;num-traits-%commit%'
)

LLVM_COMPAT=( {20..23} )
MODULES_INITRAMFS_IUSE=+initramfs
MODULES_KERNEL_MIN=6.16
MODULES_OPTIONAL_IUSE=+modules
PYTHON_COMPAT=( python3_{12..15} )
RUST_MIN_VER="1.89.0"
RUST_NEEDS_LLVM=1
VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/kentoverstreet.asc

# for _pre* snapshots
# git -c safe.directory=$PWD -c core.abbrev=12 describe
# ("v${PV}" if unset)
BCH_VERSION=v1.39.7-3686-gd48f401d37ff

inherit cargo flag-o-matic linux-mod-r1 llvm-r2 multiprocessing python-any-r1
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
LICENSE+="
	0BSD
	Apache-2.0
	BSD
	BSD-2
	Boost-1.0
	GPL-2
	ISC
	MIT
	Unicode-3.0
"

SLOT="0"
IUSE="debug"

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
	dev-libs/userspace-rcu:=
	sys-apps/util-linux
	virtual/zlib:=
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
	modules? (
		>=sys-kernel/linux-headers-${MODULES_KERNEL_MIN}.0
	)
	verify-sig? ( >=sec-keys/openpgp-keys-kentoverstreet-20241012 )
	${RUST_DEPEND}
"

QA_FLAGS_IGNORED="sbin/bcachefs"

PATCHES=(
	"${FILESDIR}/1.40.0_pre20261125091918-no-env-set.patch"
)

python_check_deps() {
	python_has_version "dev-python/docutils[${PYTHON_USEDEP}]"
}

pkg_setup() {
	# early llvm_prepend_path
	# to keep C and Rust synced
	if [[ ${MERGE_TYPE} != binary ]]; then
		llvm_prepend_path "${LLVM_SLOT}"
	fi

	llvm-r2_pkg_setup
	python-any-r1_pkg_setup
	rust_pkg_setup
	if use modules; then
		# grep -r 'depends on\|select ' ${S}/fs/Kconfig | grep -v '^#'
		local CONFIG_CHECK="
			RUST
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

	# the double patch (first project's Cargo.toml "patch.crates-io",
	# then cargo.eclass's config.toml "patch.'<url>'")
	# confuses cargo and somehow the one from Cargo.toml wins
	local crate path
	for crate in fuser num-traits; do
		path=$(
			set -o pipefail
			grep '^'"${crate}"' = { path =' "${WORKDIR}/cargo_home/config.toml" \
			| sed -E -e 's/.*path = "(.*)".*/\1/' \
			|| die "Could not parse local ${crate} crate path"
		)
		einfo "Pointing Cargo.toml to local ${crate} at ${path}"
		sed -E -i -e '/^'"${crate}"' = \{ git =/s|\{.*\}|\{ path = "'"${path}"'" \}|' Cargo.toml || die
	done

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
	local -a templates=(
		bcachefs-wait-devices@.service.in
		dracut/90bcachefs/module-setup.sh.in
		udev/64-bcachefs.rules.in
	)
	for template in "${templates[@]}"; do
		cp "${template}" "${template%.in}" || die
		sed -i \
			-e 's|@sbindir@|/sbin|g' \
			-e 's|@ROOT_SBINDIR@|/sbin|g' \
			"${template%.in}" || die
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

	# systemd units/generators
	dosym -r /sbin/bcachefs "$(systemd_get_systemgeneratordir)/bcachefs-mount-generator"
	systemd_dounit bcachefs-wait-devices@.service

	# dracut module
	# (unconditional: small and doesn't force
	# installation of stuff to initramfs with
	# hostonly unless rootfs is bcachefs)
	insinto /usr/lib/dracut/modules.d/90bcachefs
	doins dracut/90bcachefs/module-setup.sh
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
