# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 17 18 )

inherit linux-info llvm-r1 cargo meson git-r3

DESCRIPTION="sched_ext schedulers and tools"
HOMEPAGE="https://github.com/sched-ext/scx"
EGIT_REPO_URI="https://github.com/sched-ext/scx"

BPFTOOL_REPO_URI="https://github.com/libbpf/bpftool"
LIBBPF_REPO_URI="https://github.com/libbpf/libbpf"

# we need to bundle bpftool for skeleton support
# these are just for the build, scx scheds will link
# to system libbpf
BPFTOOL_COMMIT="20ce6933869b70bacfdd0dd1a8399199290bf8ff"
LIBBPF_COMMIT="20ea95b4505c477af3b6ff6ce9d19cee868ddc5d"

LICENSE="GPL-2"
SLOT="0"
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

# default but already needed in src_prepare
BUILD_DIR="${WORKDIR}/${P}-build"

src_unpack() {
	# main src
	git-r3_src_unpack

	# bpf src
	(
		EGIT_REPO_URI="${BPFTOOL_REPO_URI}"
		EGIT_CHECKOUT_DIR="${WORKDIR}/bpftool"
		EGIT_COMMIT="${BPFTOOL_COMMIT}"
		git-r3_src_unpack
		EGIT_REPO_URI="${LIBBPF_REPO_URI}"
		EGIT_CHECKOUT_DIR="${WORKDIR}/libbpf"
		EGIT_COMMIT="${LIBBPF_COMMIT}"
		git-r3_src_unpack
	)

	# rust src
	# vendor each to it's own dir...
	shopt -s globstar
	for manifest in ${S}/**/Cargo.toml; do
		(
			S="${manifest%/*}"
			ECARGO_VENDOR="${ECARGO_VENDOR}-${S##*/}"
			cargo() {
				local args=( "${@}" )
				case "${args[0]}" in
					vendor) /usr/bin/cargo vendor --versioned-dirs "${args[@]:1}";;
					*) /usr/bin/cargo "${args[@]}";;
				esac
			}
			einfo "Vendoring ${ECARGO_VENDOR}"
			cargo_live_src_unpack
		)
	done
	shopt -u globstar

	# ...then merge
	einfo "Merging ECARGO_VENDOR dirs"
	mkdir -p "${ECARGO_VENDOR}" || die
	for dir in "${ECARGO_VENDOR}"-*; do
		for crate in "${dir}"/*; do
			if [[ ! -d "${ECARGO_VENDOR}/${crate##*/}" ]]; then
				einfo ">>> ${crate##*/}"
				mv "${crate}" "${ECARGO_VENDOR}" || die
			fi
		done
		rm -rf "${dir}" || die
	done
	cargo_gen_config
}

pkg_setup() {
	linux-info_pkg_setup
	llvm-r1_pkg_setup
}

src_prepare() {
	default

	# handle the bpftool fetching logic via ebuild
	echo "#!/bin/sh" > meson-scripts/fetch_bpftool || die
	mkdir -p "${BUILD_DIR}" || die
	mv "${WORKDIR}/bpftool" "${BUILD_DIR}/bpftool" || die
	rm -r "${BUILD_DIR}/bpftool/libbpf" || die
	mv "${WORKDIR}/libbpf" "${BUILD_DIR}/bpftool/libbpf" || die
}

src_configure() {
    cargo_src_configure --frozen
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
