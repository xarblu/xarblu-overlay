# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034,SC2155

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

RUST_MIN_VER="1.83.0"
RUST_NEEDS_LLVM=1
RUST_OPTIONAL=1
RUST_REQ_USE="rust-src"
LLVM_COMPAT=( {19..22} )
LLVM_OPTIONAL=1

inherit eapi9-pipestatus toolchain-funcs flag-o-matic llvm-r1 rust kernel-build

# https://dev.gentoo.org/~mgorny/dist/linux/
GENTOO_PATCHSET=linux-gentoo-patches-6.19.6
# https://github.com/projg2/gentoo-kernel-config
GENTOO_CONFIG_VER=g18
# https://github.com/CachyOS/linux-cachyos
CONFIG_COMMIT=69fe4c4eb675d157869579d05fe69d3399b04e50
# https://github.com/CachyOS/kernel-patches
PATCH_COMMIT=721e793b3927461e594270965aaccb2806763304
# bcachefs backports version
# https://github.com/koverstreet/bcachefs-tools
# https://github.com/xarblu/bcachefs-patches
BCACHEFS_VER=1.37.6_pre20260407172151
# cachyos tarball release (usually 1)
# https://github.com/CachyOS/linux
CACHY_REL=3

# supported linux-cachyos flavours from CachyOS/linux-cachyos (excl. lts/rc)
FLAVOURS="cachyos bmq bore deckify eevdf rt-bore server"

# array of patches in format
# <use>:<path/to.patch>
# special use - always applies patch
# applied in this order
CACHY_PATCH_SPECS=(
	# flavours
	bmq:sched/0001-prjc-cachy.patch
	bore:sched/0001-bore-cachy.patch
	deckify:misc/0001-acpi-call.patch
	deckify:misc/0001-handheld.patch
	deckify:sched/0001-bore-cachy.patch
	rt-bore:sched/0001-bore-cachy.patch
	rt-bore:misc/0001-rt-i915.patch
	# clang
	clang:misc/dkms-clang.patch
)

# bad patches that don't apply properly
# usually these are genpatches that are also included in the cachyos-base-all patch
# or genpatches that are not rebased yet (common for RCs)
BAD_PATCHES=(
	2004_sign-file-full-functionality-with-modern-LibreSSL.patch
)

# Parse Kernel version vars from PV
# KERNEL_BASE  - base linux version
# KERNEL_RC    - release candidate patch target
# KERNEL_PATCH - stable patch target
# KERNEL_REL   - _p* version bumped on changes to config/patch vars (0 if unset)
if [[ "${PV}" == *_rc* ]]; then
	# release candidate
	KERNEL_BASE="$(ver_cut 1-2)"
	KERNEL_RC="${PV##*_rc}"
	KERNEL_RC="${KERNEL_RC%_p*}"
	KERNEL_PATCH="0"
	KERNEL_REL="${PV##*_p}"

	FLAVOURS="cachyos"
elif [[ "${PV}" == *_pre* ]]; then
	# transitional testing version during merge window
	# tracks stable releases of the last mainline
	if [[ "${PV}" == 7.0* ]]; then
		KERNEL_BASE="6.19"
	else
		KERNEL_BASE="$(ver_cut 1).$(( $(ver_cut 2) - 1 ))"
	fi
	KERNEL_RC="0"
	KERNEL_PATCH="${PV##*_pre}"
	KERNEL_PATCH="${KERNEL_RC%_p*}"
	KERNEL_REL="${PV##*_p}"

	FLAVOURS="cachyos"
else
	# stable
	KERNEL_BASE="$(ver_cut 1-2)"
	KERNEL_RC="0"
	KERNEL_PATCH="$(ver_cut 3)"
	KERNEL_REL="${PV##*_p}"

	KEYWORDS="~amd64"
fi

# default 0 if unset, else whatever is in _p*
[[ "${PV}" == "${KERNEL_REL}" ]] && KERNEL_REL="0"

# cachy stuff versions
CONFIG_P="${PN}-${KERNEL_BASE}-${CONFIG_COMMIT::8}"
PATCH_P="${PN}-${KERNEL_BASE}-${PATCH_COMMIT::8}"

DESCRIPTION="Linux kernel built with CachyOS and Gentoo patches"
HOMEPAGE="
	https://cachyos.org/
	https://github.com/CachyOS/linux-cachyos/
	https://www.kernel.org/
"

# Gentoo patches and config
# the rest will be set via helpers below
SRC_URI="
	https://dev.gentoo.org/~mgorny/dist/linux/${GENTOO_PATCHSET}.tar.xz
	https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
"

IUSE="bcachefs cfi clang debug lto rust scx ${FLAVOURS/cachyos/+cachyos}"
REQUIRED_USE="
	^^ ( ${FLAVOURS} )
	bcachefs? ( rust )
	cfi? ( clang )
	clang? ( ${LLVM_REQUIRED_USE} )
	lto? ( clang )
	rust? ( ${LLVM_REQUIRED_USE} )
"

# CONFIG_RUST requires this:
# (!DEBUG_INFO_BTF || PAHOLE_HAS_LANG_EXCLUDE && !LTO)
# CONFIG_DEBUG_INFO_BTF and CONFIG_LTO are mutually exclusive
REQUIRED_USE+="
	rust? ( lto? ( !debug !scx ) )
"

# shellcheck disable=SC2016 # we don't want LLVM_SLOT to expand
BDEPEND="
	clang? ( $(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}=
		llvm-core/lld:${LLVM_SLOT}=
		llvm-core/llvm:${LLVM_SLOT}=
	') )
	rust? (
		$(llvm_gen_dep 'llvm-core/clang:${LLVM_SLOT}=')
		dev-util/bindgen
		${RUST_DEPEND}
	)
	debug? ( dev-util/pahole )
	scx? ( dev-util/pahole )
"
PDEPEND="
	>=virtual/dist-kernel-${PV}
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

# append a list of kernel sources and incremental patches to SRC_URI
# and sets S to the correct directory
kernel_base_env_setup() {
	local base_uri="https://github.com/CachyOS/linux/releases/download"

	if (( KERNEL_RC > 0 )); then
		SRC_URI+=" ${base_uri}/cachyos-${KERNEL_BASE}-rc${KERNEL_RC}-${CACHY_REL}/cachyos-${KERNEL_BASE}-rc${KERNEL_RC}-${CACHY_REL}.tar.gz"
		S="${WORKDIR}/cachyos-${KERNEL_BASE}-rc${KERNEL_RC}-${CACHY_REL}"
	else
		SRC_URI+=" ${base_uri}/cachyos-${KERNEL_BASE}.${KERNEL_PATCH}-${CACHY_REL}/cachyos-${KERNEL_BASE}.${KERNEL_PATCH}-${CACHY_REL}.tar.gz"
		S="${WORKDIR}/cachyos-${KERNEL_BASE}.${KERNEL_PATCH}-${CACHY_REL}"
	fi
}

# adds cachyos config sources to SRC_URI
cachy_config_env_setup() {
	local base spec cond patch file flavour
	local cachy_config_uris=""
	base="https://raw.githubusercontent.com/CachyOS/linux-cachyos"
	base+="/${CONFIG_COMMIT}"
	if [[ ${PV} == *_rc* ]]; then
		# RC only has cachyos flavour
		cachy_config_uris+="${base}/linux-cachyos-rc/config -> ${CONFIG_P}-cachyos.config "
	else
		for flavour in ${FLAVOURS}; do
			file="${CONFIG_P}-${flavour}.config"
			if [[ "${flavour}" == "cachyos" ]]; then
				cachy_config_uris+="${flavour}? ( ${base}/linux-cachyos/config -> ${file} ) "
			else
				cachy_config_uris+="${flavour}? ( ${base}/linux-cachyos-${flavour}/config -> ${file} ) "
			fi
		done
	fi
	declare -g SRC_URI="${SRC_URI} ${cachy_config_uris}"
}

# adds cachyos patch sources to SRC_URI
# and sets up IUSE_PATTERN to check if a flag is in IUSE
cachy_patch_env_setup() {
	local -a iuse_arr
	read -r -a iuse_arr <<<"${IUSE}"
	iuse_arr=( "${iuse_arr[@]#+}" )
	local IFS="|"
	declare -g IUSE_PATTERN="${iuse_arr[*]}"
	unset IFS

	local base spec cond patch file
	local cachy_patch_uris=""
	base="https://raw.githubusercontent.com/CachyOS/kernel-patches"
	base+="/${PATCH_COMMIT}/${KERNEL_BASE}"
	for spec in "${CACHY_PATCH_SPECS[@]}"; do
		IFS=":" read -r cond patch <<<"${spec}"
		file="${PATCH_P}-${patch##*/}"
		if [[ "${cond}" == "-" ]]; then
			cachy_patch_uris+="${base}/${patch} -> ${file} "
		elif [[ "${cond}" =~ ${IUSE_PATTERN} ]]; then
			cachy_patch_uris+="${cond}? ( ${base}/${patch} -> ${file} ) "
		fi
	done
	declare -g SRC_URI="${SRC_URI} ${cachy_patch_uris}"
}

# adds bcachefs backport patch to SRC_URI
bcachefs_patch_env_setup() {
	[[ -z "${BCACHEFS_VER}" ]] && return

	declare -g BCACHEFS_PATCH="bcachefs-v${BCACHEFS_VER}-for-v${KERNEL_BASE}.patch"
	declare -g SRC_URI="${SRC_URI} bcachefs? (
		https://raw.githubusercontent.com/xarblu/bcachefs-patches/refs/heads/main/${KERNEL_BASE}/${BCACHEFS_PATCH}
	)"

	# enforce bcachefs-tools version on minor-level
	# to make sure there are no weird kernel/user-space
	# incompatibilities
	local bch_tools_min
	if [[ "${BCACHEFS_VER}" == *_pre* ]]; then
		bch_tools_min="$(ver_cut 1-2 "${BCACHEFS_VER}").0_pre0"
	else
		bch_tools_min="$(ver_cut 1-2 "${BCACHEFS_VER}").0"
	fi

	RDEPEND+="
		bcachefs? (
			>=sys-fs/bcachefs-tools-${bch_tools_min}
		)
	"
}

# env setup helpers
kernel_base_env_setup
cachy_config_env_setup
cachy_patch_env_setup
bcachefs_patch_env_setup

# get the selected flavour from FLAVOURS
cachy_flavour() {
	local flavour
	for flavour in ${FLAVOURS}; do
		if use "${flavour}"; then
			printf -- "%s" "${flavour}" || die
			return 0
		fi
	done
	die "Could not get selected flavour"
}

# get the config file name
cachy_base_config() {
	printf -- "%s-%s.config" "${CONFIG_P}" "$(cachy_flavour)" || die
}

# move required patches to ${WORKDIR}/patches
# and ensure they get applied in correct order
cachy_stage_patches() {
	local target="${WORKDIR}/patches"
	einfo "Staging patches to be applied in ${target} ..."
	mkdir -p "${target}" || die

	# Gentoo patches live in ${WORKDIR}/${GENTOO_PATCHSET}
	pushd "${WORKDIR}/${GENTOO_PATCHSET}" >/dev/null || die
	local incr=2000
	local file
	for file in *.patch; do
		cp "${file}" "${target}/${incr}_${file#????-}" || die
		incr=$(( incr + 1 ))

		# we want everything up to the Gentoo KConfig patch
		# everything after it is considered experimental
		# according to gentoo-kernel ebuild
		if [[ "${file}" == *Add-Gentoo-Linux-support-config-settings* ]]; then
			break
		fi
	done
	popd >/dev/null || die

	# cachy patches need to be prefixed starting at 6000
	local incr=6000
	local spec cond patch file
	for spec in "${CACHY_PATCH_SPECS[@]}"; do
		IFS=":" read -r cond patch <<<"${spec}" || die
		file="${PATCH_P}-${patch##*/}"
		if [[ "${cond}" == "-" ]]; then
			true
		elif [[ "${cond}" =~ ${IUSE_PATTERN} ]] && use "${cond}"; then
			true
		else
			continue
		fi
		cp "${DISTDIR}/${file}" "${target}/${incr}_${file}" || die
		incr=$(( incr + 1 ))
	done

	# bcachefs backport patch is 6500
	if use bcachefs; then
		cp "${DISTDIR}/${BCACHEFS_PATCH}" \
			"${target}/6500_${BCACHEFS_PATCH}" || die
	fi

	# remove problematic patches
	local patch
	for patch in "${BAD_PATCHES[@]}"; do
		rm "${target}/${patch}" || die
	done
}

# auto-detect closest march value
cachy_processor_opt() {
	# not supported but in case someone
	# builds on non amd64 return default
	if ! use amd64; then
		printf "GENERIC"
		return 0
	fi

	# apply X86_NATIVE_CPU if we have -march=native
	if [[ "$(get-flag march)" == native ]]; then
		printf "NATIVE"
		return 0
	fi

	# get closest march for others
	# mostly shameless rip from qt6-build.eclass
	# shellcheck disable=SC2086 # *FLAGS should split
	local march=$(
		$(tc-getCC) -E -P ${CFLAGS} ${CPPFLAGS} - <<-EOF | tail -n 1
			default
			#if (__CRC32__ + __LAHF_SAHF__ + __POPCNT__ + __SSE3__ + __SSE4_1__ + __SSE4_2__ + __SSSE3__) == 7
			x86-64-v2
			#  if (__AVX__ + __AVX2__ + __BMI__ + __BMI2__ + __F16C__ + __FMA__ + __LZCNT__ + __MOVBE__ + __XSAVE__) == 9
			x86-64-v3
			#    if (__AVX512BW__ + __AVX512CD__ + __AVX512DQ__ + __AVX512F__ + __AVX512VL__ + __EVEX256__ + __EVEX512__) == 7
			x86-64-v4
			#    endif
			#  endif
			#endif
		EOF
		pipestatus || die
	)
	case "${march}" in
		default) printf "GENERIC_V1";;
		x86-64-v2) printf "GENERIC_V2";;
		x86-64-v3) printf "GENERIC_V3";;
		x86-64-v4) printf "GENERIC_V4";;
		*) die "Got unknown march: ${march}";;
	esac
}

# print formatted kernel config line
# $1 can be one of set, unset, mod or val
# $2 config name as in CONFIG_<name>
# $3 if $1 is val set val as a config string
kconf() {
	if (( $# < 2 )); then
		die "kconf needs at least 2 args"
	fi
	case "$1" in
		set)
			printf -- "CONFIG_%s=y\n" "${2}" || die
			;;
		unset)
			printf -- "# CONFIG_%s is not set\n" "${2}" || die
			;;
		mod)
			printf -- "CONFIG_%s=m\n" "${2}" || die
			;;
		val)
			if [[ -z "${3}" ]]; then
				die "kconf val requires a value"
			fi
			printf -- "CONFIG_%s=%s\n" "${2}" "${3}" || die
			;;
		*)
			die "invalid option $1 for kconf"
			;;
	esac
}

cachy_localversion_kconfig() {
	local flavour="$(cachy_flavour)"
	case "${flavour}" in
		cachyos)
			kconf val LOCALVERSION "\"-cachyos\""
			;;
		*)
			kconf val LOCALVERSION "\"-cachyos-${flavour}\""
			;;
	esac
}

# config defaults from CachyOS PKGBUILD
cachy_flavour_defaults_kconfig() {
	# cachy config vars (only those that make sense in ebuild)
	# advanced users can override these with package.env
	case "$(cachy_flavour)" in
		cachyos)
			: "${_cachy_config:=yes}"
			: "${_cpusched:=cachyos}"
			: "${_cc_harder:=yes}"
			: "${_per_gov:=no}"
			: "${_tcp_bbr3:=no}"
			: "${_HZ_ticks:=1000}"
			: "${_tickrate:=full}"
			: "${_preempt:=full}"
			: "${_hugepage:=always}"
			;;
		bmq)
			: "${_cachy_config:=yes}"
			: "${_cpusched:=bmq}"
			: "${_cc_harder:=yes}"
			: "${_per_gov:=no}"
			: "${_tcp_bbr3:=no}"
			: "${_HZ_ticks:=1000}"
			: "${_tickrate:=full}"
			: "${_preempt:=full}"
			: "${_hugepage:=always}"
			;;
		bore)
			: "${_cachy_config:=yes}"
			: "${_cpusched:=bore}"
			: "${_cc_harder:=yes}"
			: "${_per_gov:=no}"
			: "${_tcp_bbr3:=no}"
			: "${_HZ_ticks:=1000}"
			: "${_tickrate:=full}"
			: "${_preempt:=full}"
			: "${_hugepage:=always}"
			;;
		deckify)
			: "${_cachy_config:=yes}"
			: "${_cpusched:=cachyos}"
			: "${_cc_harder:=yes}"
			: "${_per_gov:=no}"
			: "${_tcp_bbr3:=no}"
			: "${_HZ_ticks:=1000}"
			: "${_tickrate:=full}"
			: "${_preempt:=full}"
			: "${_hugepage:=always}"
			;;
		eevdf)
			: "${_cachy_config:=yes}"
			: "${_cpusched:=eevdf}"
			: "${_cc_harder:=yes}"
			: "${_per_gov:=no}"
			: "${_tcp_bbr3:=no}"
			: "${_HZ_ticks:=1000}"
			: "${_tickrate:=full}"
			: "${_preempt:=full}"
			: "${_hugepage:=always}"
			;;
		rt-bore)
			: "${_cachy_config:=yes}"
			: "${_cpusched:=rt-bore}"
			: "${_cc_harder:=yes}"
			: "${_per_gov:=no}"
			: "${_tcp_bbr3:=no}"
			: "${_HZ_ticks:=1000}"
			: "${_tickrate:=full}"
			: "${_preempt:=full}"
			: "${_hugepage:=always}"
			;;
		server)
			: "${_cachy_config:=no}"
			: "${_cpusched:=eevdf}"
			: "${_cc_harder:=yes}"
			: "${_per_gov:=no}"
			: "${_tcp_bbr3:=no}"
			: "${_HZ_ticks:=300}"
			: "${_tickrate:=idle}"
			: "${_preempt:=lazy}"
			: "${_hugepage:=always}"
			;;
		*) die "Unknown flavour" ;;
	esac

	: "${_processor_opt:="$(cachy_processor_opt)"}"

	if use cfi; then
		: "${_use_kcfi:=yes}"
	else
		: "${_use_kcfi:=no}"
	fi

	if use lto; then
		: "${_use_llvm_lto:=thin}"
	else
		: "${_use_llvm_lto:=none}"
	fi

	# print cachy config
	einfo "Selected cachy-config:"
	einfo "  _cachy_config=${_cachy_config}"
	einfo "  _cpusched=${_cpusched}"
	einfo "  _cc_harder=${_cc_harder}"
	einfo "  _per_gov=${_per_gov}"
	einfo "  _tcp_bbr3=${_tcp_bbr3}"
	einfo "  _HZ_ticks=${_HZ_ticks}"
	einfo "  _tickrate=${_tickrate}"
	einfo "  _preempt=${_preempt}"
	einfo "  _hugepage=${_hugepage}"
	einfo "  _processor_opt=${_processor_opt}"
	einfo "  _use_kcfi=${_use_kcfi}"
	einfo "  _use_llvm_lto=${_use_llvm_lto}"

	# _processor_opt
	local MARCH="${_processor_opt^^}"
	case "${MARCH}" in
		GENERIC) ;;
		GENERIC_V[1-4])
			kconf set GENERIC_CPU
			kconf unset MZEN4
			kconf unset X86_NATIVE_CPU
			kconf val X86_64_VERSION "${MARCH#GENERIC_V}"
			;;
		ZEN4)
			kconf unset GENERIC_CPU
			kconf set MZEN4
			kconf unset X86_NATIVE_CPU
			;;
		NATIVE)
			kconf unset GENERIC_CPU
			kconf unset MZEN4
			kconf set X86_NATIVE_CPU
			;;
		*) die "Invalid _processor_opt value: ${_processor_opt}" ;;
	esac

	# _cachy_config
	case "${_cachy_config}" in
		yes)
			kconf set CACHY
			;;
		no)	;;
		*) die "Invalid _cachy_config value: ${_cachy_config}" ;;
	esac

	# _cpusched
	case "${_cpusched}" in
		bore)
			kconf set SCHED_BORE
			;;
		bmq)
			kconf set SCHED_ALT
			kconf set SCHED_BMQ
			;;
		cachyos|eevdf) ;;
		rt)
			kconf set PREEMPT_RT
			;;
		rt-bore)
			kconf set SCHED_BORE
			kconf set PREEMPT_RT
			;;
		*) die "Invalid _cpusched value: ${_cpusched}" ;;
	esac

	# _use_kcfi
	case "${_use_kcfi}" in
		yes)
			kconf set CFI
			kconf set CFI_AUTO_DEFAULT
			;;
		no) ;;
		*) die "Invalid _use_kcfi value: ${_use_kcfi}" ;;
	esac

	# _use_llvm_lto
	case "${_use_llvm_lto}" in
		thin)
			kconf set LTO_CLANG_THIN
			;;
		full)
			kconf set LTO_CLANG_FULL
			;;
		none)
			kconf set LTO_NONE
			;;
		*) die "Invalid _use_llvm_lto value: ${_use_llvm_lto}" ;;
	esac

	# _HZ_ticks
	case "${_HZ_ticks}" in
		100|250|500|600|750|1000)
			kconf unset HZ_300
			kconf set "HZ_${_HZ_ticks}"
			kconf val HZ "${_HZ_ticks}"
			;;
		300)
			kconf set HZ_300
			kconf val HZ 300
			;;
		*) die "Invalid _HZ_ticks value: ${_HZ_ticks}" ;;
	esac

	# _per_gov
	case "${_per_gov}" in
		yes)
			kconf unset CPU_FREQ_DEFAULT_GOV_SCHEDUTIL
			kconf set CPU_FREQ_DEFAULT_GOV_PERFORMANCE
			;;
		no) ;;
		*) die "Invalid _per_gov value: ${_per_gov}" ;;
	esac

	# _tickrate
	case "${_tickrate}" in
		periodic)
			kconf unset NO_HZ_IDLE
			kconf unset NO_HZ_FULL
			kconf unset NO_HZ
			kconf unset NO_HZ_COMMON
			kconf set HZ_PERIODIC
			;;
		idle)
			kconf unset HZ_PERIODIC
			kconf unset NO_HZ_FULL
			kconf set NO_HZ_IDLE
			kconf set NO_HZ
			kconf set NO_HZ_COMMON
			;;
		full)
			kconf unset HZ_PERIODIC
			kconf unset NO_HZ_IDLE
			kconf set NO_HZ_FULL
			kconf set NO_HZ
			kconf set NO_HZ_COMMON
			kconf set CONTEXT_TRACKING
			;;
		*) die "Invalid _tickrate value: ${_tickrate}" ;;
	esac

	# _preempt
	if [[ "${_cpusched}" != rt* ]]; then
		case "${_preempt}" in
			full)
				kconf unset PREEMPT_DYNAMIC
				kconf set PREEMPT
				kconf unset PREEMPT_LAZY
				;;
			lazy)
				kconf unset PREEMPT_DYNAMIC
				kconf unset PREEMPT
				kconf set PREEMPT_LAZY
				;;
			dynamic)
				kconf set PREEMPT_DYNAMIC
				kconf set PREEMPT
				kconf unset PREEMPT_LAZY
				;;
			*) die "Invalid _preempt value: ${_preempt}" ;;
		esac
	fi

	# _cc_harder
	case "${_cc_harder}" in
		yes)
			kconf unset CC_OPTIMIZE_FOR_PERFORMANCE
			kconf set CC_OPTIMIZE_FOR_PERFORMANCE_O3
			;;
		no) ;;
		*) die "Invalid _cc_harder value: ${_cc_harder}" ;;
	esac

	# _tcp_bbr3
	case "${_tcp_bbr3}" in
		yes)
			kconf mod TCP_CONG_CUBIC
			kconf unset DEFAULT_CUBIC
			kconf set TCP_CONG_BBR
			kconf val DEFAULT_TCP_CONG "\"bbr\""
			if ! use server; then
				kconf mod NET_SCH_FQ_CODEL
				kconf set NET_SCH_FQ
				kconf unset CONFIG_DEFAULT_FQ_CODEL
				kconf set CONFIG_DEFAULT_FQ
			fi
			;;
		no)	;;
		*) die "Invalid _tcp_bbr3 value: ${_tcp_bbr3}" ;;
	esac

	# _hugepage
	case "${_hugepage}" in
		always)
			kconf unset TRANSPARENT_HUGEPAGE_MADVISE
			kconf set TRANSPARENT_HUGEPAGE_ALWAYS
			;;
		madvise)
			kconf unset TRANSPARENT_HUGEPAGE_ALWAYS
			kconf set TRANSPARENT_HUGEPAGE_MADVISE
			;;
		*) die "Invalid _hugepage value: ${_hugepage}" ;;
	esac

	# handheld only
	if [[ "$(cachy_flavour)" == deckify ]]; then
		kconf unset RCU_LAZY_DEFAULT_OFF
		kconf set AMD_PRIVATE_COLOR
	fi

	# rust
	if use rust; then
		kconf set RUST
	else
		kconf unset RUST
	fi

	# bcachefs defaults
	if use bcachefs; then
		kconf mod BCACHEFS_FS
		kconf set BCACHEFS_QUOTA
		kconf set BCACHEFS_LOCK_TIME_STATS
		kconf set BCACHEFS_SIX_OPTIMISTIC_SPIN
	fi
}

scx_kconfig() {
	kconf set DEBUG_KERNEL
	kconf set DEBUG_INFO
	kconf set DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
	kconf set DEBUG_INFO_BTF
	kconf set BPF
	kconf set BPF_EVENTS
	kconf set BPF_JIT
	kconf set BPF_JIT_ALWAYS_ON
	kconf set BPF_JIT_DEFAULT_ON
	kconf set BPF_SYSCALL
	kconf set SCHED_CLASS_EXT
	kconf set FTRACE
}

# verify that provided config snippets exist after make
cachy_verify_kconfig() {
	(( ${#} < 1 )) && die "requires at least 1 arg"

	local kconfig="${WORKDIR}/modprep/.config"

	if [[ ! -f "${kconfig}" ]]; then
		eerror "${kconfig} does not exist"
		die "Did you call kernel-build_src_configure?"
	fi

	einfo "Verifying config snippets..."

	local snippet line
	local bad_config="false"
	for snippet; do
		einfo "Checking ${snippet}..."
		while read -r line; do
			if ! grep -q -F "${line}" "${kconfig}"; then
				ewarn "'${line}' provided in ${snippet} but not in ${kconfig}!"
				bad_config="true"
			fi
		done < <(grep -E '^(CONFIG_|# CONFIG_)' "${snippet}")
	done

	if [[ "${bad_config}" == "true" ]]; then
		ewarn "Some config snippets did not apply correctly!"
	else
		einfo "All config snippets applied correctly!"
	fi
}

pkg_pretend() {
	# die instead of just masking/dropping USE
	# to make extra sure users don't unknowingly lose
	# access to their filesystem
	if use bcachefs && [[ -z "${BCACHEFS_VER}" ]]; then
		eerror "bcachefs is currently broken on kernel $(ver_cut 1-2)"
		eerror "Failing early to make sure you know and don't lose access to your fs"
		die "broken bcachefs"
	fi

	if use bcachefs; then
		elog "This kernel will have support for bcachefs ${BCACHEFS_VER} built in"
	fi

	kernel-install_pkg_pretend
}

pkg_setup() {
	if [[ "${MERGE_TYPE}" == binary ]]; then
		kernel-build_pkg_setup
		return
	fi

	if use clang; then
		# tools passed as MAKEARGS in kernel-build.eclass
		einfo "Forcing LLVM toolchain due to USE=clang"
		declare -g AS="llvm-as"
		declare -g CC="clang"
		declare -g LD="ld.lld"
		declare -g AR="llvm-ar"
		declare -g NM="llvm-nm"
		declare -g STRIP="llvm-strip"
		declare -g OBJCOPY="llvm-objcopy"
		declare -g OBJDUMP="llvm-objdump"
		declare -g READELF="llvm-readelf"
		# explicit prepend_path to ensure vars point to correct version
		llvm_prepend_path -b "${LLVM_SLOT}"
	fi

	if use clang || use rust; then
		llvm-r1_pkg_setup
	fi

	if use rust; then
		rust_pkg_setup
	fi

	einfo "Effective toolchain:"
	einfo "AS: ${AS}"
	einfo "CC: ${CC}"
	einfo "LD: ${LD}"
	einfo "AR: ${AR}"
	einfo "NM: ${NM}"
	einfo "STRIP: ${STRIP}"
	einfo "OBJCOPY: ${OBJCOPY}"
	einfo "OBJDUMP: ${OBJDUMP}"
	einfo "READELF: ${READELF}"
	einfo "RUSTC: ${RUSTC}"

	kernel-build_pkg_setup
}

src_prepare() {
	# prepare and stage patches
	cachy_stage_patches

	# apply package and user patches
	eapply "${WORKDIR}/patches"
	eapply_user

	local extraversion

	# keep existing info
	extraversion="$(grep '^EXTRAVERSION = ' Makefile | sed -e 's:^EXTRAVERSION = \(.*\)$:\1:' || die)"

	# bump everything to our testing version
	if [[ "${PV}" == *_pre* ]]; then
		sed -i -e "s:^\(VERSION =\).*:\1 $(ver_cut 1):" Makefile || die
		sed -i -e "s:^\(PATCHLEVEL =\).*:\1 $(ver_cut 2):" Makefile || die
		sed -i -e "s:^\(SUBLEVEL =\).*:\1 0:" Makefile || die
		extraversion+="-pre${KERNEL_PATCH}"
	fi

	# KERNEL_REL 0 doesn't need extraversion
	if (( KERNEL_REL > 0 )); then
		# dist-kernel_PV_to_KV only converts the first "_" to "-"
		# instead of fighting that we'll just use the
		# slightly uglier -(rc|pre)*_p*
		if [[ -z "${extraversion}" ]]; then
			extraversion+="-p${KERNEL_REL}"
		else
			extraversion+="_p${KERNEL_REL}"
		fi
	fi

	# add extraversion
	if [[ -n "${extraversion}" ]]; then
		sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${extraversion}:" Makefile || die
	fi

	# Localversion
	cachy_localversion_kconfig > "${T}/cachy-localversion.config" || die

	# CachyOS config as base
	cp "${DISTDIR}/$(cachy_base_config)" .config || die

	# Package defaults
	cachy_flavour_defaults_kconfig > "${T}/cachy-flavour-defaults.config" || die

	# Gentoo defaults
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

	local merge_configs=(
		"${T}/cachy-localversion.config"
		"${dist_conf_path}/base.config"
		"${dist_conf_path}/6.12+.config"
		"${T}/cachy-flavour-defaults.config"
	)

	use debug || merge_configs+=(
		"${dist_conf_path}/no-debug.config"
	)

	# partially reverts no-debug.config so must come after that one
	if use scx; then
		scx_kconfig > "${T}/scx.config" || die
		merge_configs+=( "${T}/scx.config" )
	fi

	use secureboot && merge_configs+=(
		"${dist_conf_path}/secureboot.config"
		"${dist_conf_path}/zboot.config"
	)

	kernel-build_merge_configs "${merge_configs[@]}"
}

src_configure() {
	kernel-build_src_configure

	# Only check our ebuild generated configs.
	# Users will likely expect these to work
	# because they're set via USE flags.
	# The others are to broad to check and throw too
	# many false positives.
	local check_configs=(
		"${T}/cachy-localversion.config"
		"${T}/cachy-flavour-defaults.config"
	)
	use scx && merge_configs+=( "${T}/scx.config" )

	cachy_verify_kconfig "${check_configs[@]}"
}

pkg_postinst() {
	kernel-build_pkg_postinst

	# print info for included modules
	if use bcachefs && has_version sys-fs/bcachefs-kmod; then
		elog "bcachefs ${BCACHEFS_VER} is included in ${CATEGORY}/${PN} - no need for sys-fs/bcachefs-kmod"
	fi

	if has_version media-video/v4l2loopback; then
		elog "v4l2loopback is included in ${CATEGORY}/${PN} - no need for media-video/v4l2loopback"
	fi
}
