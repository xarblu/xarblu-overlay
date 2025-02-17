# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

LLVM_COMPAT=( {17..21} )
LLVM_OPTIONAL=1

inherit llvm-r2 kernel-build

MY_P=linux-${PV%.*}

# https://dev.gentoo.org/~mpagano/genpatches/kernels.html
GENPATCHES_P=genpatches-${PV%.*}-$(( ${PV##*.} + 1 ))
# https://github.com/projg2/gentoo-kernel-config
GENTOO_CONFIG_VER=g15
# https://github.com/CachyOS/linux-cachyos
CONFIG_COMMIT="141ab3babc9cc33ba010e9d21fe8753314013003"
CONFIG_PV="${PV}-${CONFIG_COMMIT::8}"
CONFIG_P="${PN}-${CONFIG_PV}"
# https://github.com/CachyOS/kernel-patches
PATCH_COMMIT="b12399240fa83142e9dcfbb5409e27e1cc5e8e76"
PATCH_PV="${PV}-${PATCH_COMMIT::8}"
PATCH_P="${PN}-${PATCH_PV}"

# supported linux-cachyos flavours from CachyOS/linux-cachyos (excl. lts/rc)
FLAVOURS="cachyos bmq bore deckify eevdf hardened rt-bore server"

# array of patches in format
# <use>:<path/to.patch>
# special use - always applies patch
# applied in this order
CACHY_PATCH_SPECS=(
	# global
	-:all/0001-cachyos-base-all.patch
	# flavours
	cachyos:sched/0001-bore-cachy.patch
	bmq:sched/0001-prjc-cachy.patch
	bore:sched/0001-bore-cachy.patch
	deckify:misc/0001-acpi-call.patch
	deckify:misc/0001-handheld.patch
	deckify:sched/0001-bore-cachy.patch
	hardened:sched/0001-bore-cachy.patch
	#hardened:misc/0001-hardened.patch
	rt-bore:sched/0001-bore-cachy.patch
	rt-bore:misc/0001-rt-i915.patch
	# lto
	lto:misc/dkms-clang.patch
)

# build use dependent CACHY_CONFIG_URIS
# repo archive includes a bunch of old stuff we don't need
gen_cachy_config_uris() {
	local base spec cond patch file
	base="https://raw.githubusercontent.com/CachyOS/linux-cachyos"
	base+="/${CONFIG_COMMIT}"
	for flavour in ${FLAVOURS}; do
		file="${CONFIG_P}-${flavour}.config"
		if [[ "${flavour}" == "cachyos" ]]; then
			CACHY_CONFIG_URIS+="${flavour}? ( ${base}/linux-cachyos/config -> ${file} ) "
		else
			CACHY_CONFIG_URIS+="${flavour}? ( ${base}/linux-cachyos-${flavour}/config -> ${file} ) "
		fi
	done
	export CACHY_CONFIG_URIS
}
gen_cachy_config_uris

# build use dependent CACHY_PATCH_URIS
# repo archive includes a bunch of old stuff we don't need
gen_cachy_patch_uris() {
	local base spec cond patch file
	base="https://raw.githubusercontent.com/CachyOS/kernel-patches"
	base+="/${PATCH_COMMIT}/$(ver_cut 1-2)"
	for spec in "${CACHY_PATCH_SPECS[@]}"; do
		IFS=":" read -r cond patch <<<"${spec}"
		file="${PATCH_P}-${patch##*/}"
		if [[ "${cond}" == "-" ]]; then
			CACHY_PATCH_URIS+="${base}/${patch} -> ${file} "
		else
			CACHY_PATCH_URIS+="${cond}? ( ${base}/${patch} -> ${file} ) "
		fi
	done
	export CACHY_PATCH_URIS
}
gen_cachy_patch_uris

DESCRIPTION="Linux kernel built with CachyOS and Gentoo patches"
HOMEPAGE="
	https://cachyos.org/
	https://github.com/CachyOS/linux-cachyos/
	https://www.kernel.org/
"
SRC_URI+="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${MY_P}.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/${GENPATCHES_P}.base.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/${GENPATCHES_P}.extras.tar.xz
	https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
	${CACHY_CONFIG_URIS} ${CACHY_PATCH_URIS}
"
S=${WORKDIR}/${MY_P}

KEYWORDS="~amd64"
IUSE="clang debug lto ${FLAVOURS/cachyos/+cachyos}"
REQUIRED_USE="
	^^ ( ${FLAVOURS} )
	lto? ( clang )
	clang? ( ${LLVM_REQUIRED_USE} )
"

BDEPEND="
	clang? ( $(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}=
		llvm-core/lld:${LLVM_SLOT}=
		llvm-core/llvm:${LLVM_SLOT}=
	') )
	debug? ( dev-util/pahole )
"
PDEPEND="
	>=virtual/dist-kernel-${PV}
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

# get the "cachy name" of the kernel
# as in CachyOS/linux-cachyos repo
cachy_get_version() {
	local flavour
	for flavour in ${FLAVOURS}; do
		if use "${flavour}"; then
			if [[ "${flavour}" == "cachyos" ]]; then
				echo "-cachyos" || die
			else
				echo "-cachyos-${flavour}" || die
			fi
			return
		fi
	done
}

# get the config file name
cachy_get_base_config() {
	local flavour
	for flavour in ${FLAVOURS}; do
		if use ${flavour}; then
			echo "${CONFIG_P}-${flavour}.config"
		fi
	done
}

# get the patches based on flavour choice
cachy_get_patches() {
	local spec cond patch patches
	for spec in "${CACHY_PATCH_SPECS[@]}"; do
		IFS=":" read -r cond patch <<<"${spec}" || die
		if [[ "${cond}" == "-" ]] || use "${cond}"; then
			patches+="${DISTDIR}/${PATCH_P}-${patch##*/} "
		fi
	done
	echo ${patches} || die
}

# echo formatted kernel config line
# $1 can be one of set, unset, mod or val
# $2 config name as in CONFIG_<name>
# $3 if $1 is val set val as a config string
kconf() {
	if [[ $# -lt 2 ]]; then
		die "kconf needs at least 2 args"
	fi
	case "$1" in
		set)
			echo "CONFIG_$2=y"
			;;
		unset)
			echo "# CONFIG_$2 is not set"
			;;
		mod)
			echo "CONFIG_$2=m"
			;;
		val)
			if [[ -z "${3}" ]]; then
				die "kconf val requires a value"
			fi
			echo "CONFIG_$2=$3"
			;;
		*)
			die "invalid option $1 for kconf"
			;;
	esac
}

# config defaults from Arch PKGBUILD
cachy_get_use_config() {
	# relevent config vars
	local _cachy_config _cpusched _tcp_bbr3 _HZ_ticks _tickrate _preempt _hugepage _use_llvm_lto
	if use cachyos; then
		_cachy_config=y
		_cpusched=cachyos
		_tcp_bbr3=n
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use bmq; then
		_cachy_config=y
		_cpusched=bmq
		_tcp_bbr3=n
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use bore; then
		_cachy_config=y
		_cpusched=bore
		_tcp_bbr3=n
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use deckify; then
		_cachy_config=y
		_cpusched=cachyos
		_tcp_bbr3=n
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use eevdf; then
		_cachy_config=y
		_cpusched=eevdf
		_tcp_bbr3=n
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use hardened; then
		_cachy_config=y
		_cpusched=hardened
		_tcp_bbr3=n
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=madvise
	elif use rt-bore; then
		_cachy_config=y
		_cpusched=rt-bore
		_tcp_bbr3=n
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use server; then
		_cachy_config=n
		_cpusched=eevdf
		_tcp_bbr3=n
		_HZ_ticks=300
		_tickrate=idle
		_preempt=none
		_hugepage=always
	fi

	if use lto; then
		_use_llvm_lto=thin
	else
		_use_llvm_lto=none
	fi

	# _cachy_config
	case "${_cachy_config}" in
		y)
			kconf set CACHY
			;;
		n)	;;
		*)
			die "Invalid _cachy_config value: ${_cachy_config}"
			;;
	esac

	# _cpusched
	case "${_cpusched}" in
		cachyos|bore|hardened)
			kconf set SCHED_BORE
			;;
		bmq)
			kconf set SCHED_ALT
			kconf set SCHED_BMQ
			;;
		eevdf) ;;
		rt)
			kconf set PREEMPT_RT
			;;
		rt-bore)
			kconf set SCHED_BORE
			kconf set PREEMPT_RT
			;;
		*)
			die "Invalid _cpusched value: ${_cpusched}"
			;;
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
		*)
			die "Invalid _use_llvm_lto value: ${_use_llvm_lto}"
			;;
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
		*)
			die "Invalid _HZ_ticks value: ${_HZ_ticks}"
			;;
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
			kconf unset CONTEXT_TRACKING_FORCE
			kconf set NO_HZ_FULL_NODEF
			kconf set NO_HZ_FULL
			kconf set NO_HZ
			kconf set NO_HZ_COMMON
			kconf set CONTEXT_TRACKING
			;;
		*)
			die "Invalid _tickrate value: ${_tickrate}"
			;;
	esac

	# _preempt
	if [[ "${_cpusched}" != rt* ]]; then
		case "${_preempt}" in
			full)
				kconf set PREEMPT_DYNAMIC
				kconf set PREEMPT
				kconf unset PREEMPT_VOLUNTARY
				kconf unset PREEMPT_LAZY
				kconf unset PREEMPT_NONE
				;;
			lazy)
				kconf set PREEMPT_DYNAMIC
				kconf unset PREEMPT
				kconf unset PREEMPT_VOLUNTARY
				kconf set PREEMPT_LAZY
				kconf unset PREEMPT_NONE
				;;
			voluntary)
				kconf unset PREEMPT_DYNAMIC
				kconf unset PREEMPT
				kconf set PREEMPT_VOLUNTARY
				kconf unset PREEMPT_LAZY
				kconf unset PREEMPT_NONE
				;;
			none)
				kconf unset PREEMPT_DYNAMIC
				kconf unset PREEMPT
				kconf unset PREEMPT_VOLUNTARY
				kconf unset PREEMPT_LAZY
				kconf set PREEMPT_NONE
				;;
			*)
				die "Invalid _preempt value: ${_preempt}"
				;;
		esac
	fi

	# _cc_harder
	kconf unset CC_OPTIMIZE_FOR_PERFORMANCE
	kconf set CC_OPTIMIZE_FOR_PERFORMANCE_O3

	# _tcp_bbr3
	case "${_tcp_bbr3}" in
		y)
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
		n)	;;
		*)
			die "Invalid _tcp_bbr3 value: ${_tcp_bbr3}"
			;;
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
		*)
			die "Invalid _hugepage value: ${_hugepage}"
			;;
	esac

	# _user_ns
	kconf set USER_NS
}

pkg_setup() {
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
		llvm-r2_pkg_setup
		einfo "AS: ${AS}"
		einfo "CC: ${CC}"
		einfo "LD: ${LD}"
		einfo "AR: ${AR}"
		einfo "NM: ${NM}"
		einfo "STRIP: ${STRIP}"
		einfo "OBJCOPY: ${OBJCOPY}"
		einfo "OBJDUMP: ${OBJDUMP}"
		einfo "READELF: ${READELF}"
	fi
	kernel-build_pkg_setup
}

src_prepare() {
	local PATCHES=(
		# meh, genpatches have no directory
		"${WORKDIR}"/*.patch
		# CachyOS Patches
		$(cachy_get_patches)
	)
	default

	# Localversion
	kconf val LOCALVERSION "\"$(cachy_get_version)\"" > "${T}"/version.config || die

	# CachyOS config as base
	cp "${DISTDIR}/$(cachy_get_base_config)" .config || die

	# Package defaults
	cachy_get_use_config > "${T}"/cachy-flavour-defaults.config || die

	# Gentoo defaults
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

	local merge_configs=(
		"${T}"/version.config
		"${dist_conf_path}"/base.config
		"${T}"/cachy-flavour-defaults.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)

	use secureboot && merge_configs+=( "${dist_conf_path}/secureboot.config" )

	kernel-build_merge_configs "${merge_configs[@]}"
}
