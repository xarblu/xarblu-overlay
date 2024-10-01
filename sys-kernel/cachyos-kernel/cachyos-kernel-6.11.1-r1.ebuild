# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

inherit kernel-build

MY_P=linux-${PV%.*}

# https://dev.gentoo.org/~mpagano/genpatches/kernels.html
GENPATCHES_P=genpatches-${PV%.*}-$(( ${PV##*.} + 1 ))
# https://github.com/projg2/gentoo-kernel-config
GENTOO_CONFIG_VER=g13
# https://github.com/CachyOS/linux-cachyos
CONFIG_COMMIT="9de83922742a57a1c23c0e0533076a20e88999fd"
CONFIG_PV="${PV}-${CONFIG_COMMIT::8}"
CONFIG_P="${PN}-${CONFIG_PV}"
# https://github.com/CachyOS/kernel-patches
PATCH_COMMIT="168986ed56fa48061ec89d77a0f124c049a9699b"
PATCH_PV="${PV}-${PATCH_COMMIT::8}"
PATCH_P="${PN}-${PATCH_PV}"

# supported linux-cachyos flavours from CachyOS/linux-cachyos (excl. lts/rc)
FLAVOURS="cachyos bmq bore deckify eevdf hardened rt-bore sched-ext server"

# array of patches in format
# <use>:<path/to.patch>
# special use - always applies patch
# applied in this order
CACHY_PATCH_SPECS=(
	# global
	-:all/0001-cachyos-base-all.patch
	deckify:misc/0001-acpi-call.patch
	deckify:misc/0001-handheld.patch
	deckify:misc/0001-wifi-ath11k-Rename-QCA2066-fw-dir-to-QCA206X.patch
	# _cpusched
	cachyos:sched/0001-sched-ext.patch
	cachyos:sched/0001-bore-cachy-ext.patch
	bore:sched/0001-bore-cachy.patch
	bmq:sched/0001-prjc-cachy.patch
	eevdf:sched/0001-eevdf-next.patch
	server:sched/0001-eevdf-next.patch # server selects eevdf
	rt-bore:misc/0001-rt.patch
	rt-bore:sched/0001-bore-cachy-rt.patch
	#hardened:sched/0001-bore-cachy.patch
	#hardened:misc/0001-hardened.patch
	sched-ext:sched/0001-sched-ext.patch
)

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
	https://dev.gentoo.org/~alicef/dist/genpatches/${GENPATCHES_P}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/${GENPATCHES_P}.extras.tar.xz
	https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
	https://raw.githubusercontent.com/CachyOS/linux-cachyos/${CONFIG_COMMIT}/linux-cachyos/config
		-> ${CONFIG_P}-kernel.config
	${CACHY_PATCH_URIS}
"
S=${WORKDIR}/${MY_P}

KEYWORDS="~amd64"
IUSE="debug ${FLAVOURS/cachyos/+cachyos}"
REQUIRED_USE="
	^^ ( ${FLAVOURS} )
"

BDEPEND="
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
				echo "linux-cachyos" || die
			else
				echo "linux-cachyos-${flavour}" || die
			fi
			return
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
			echo "CONFIG_$2=\"$3\""
			;;
		*)
			die "invalid option $1 for kconf"
			;;
	esac
}

# config defaults from Arch PKGBUILD
cachy_get_config() {
	# first setup the _* vars (only those that differ)
	local _cachy_config _cpusched _HZ_ticks _tickrate _preempt _hugepage
	if use cachyos; then
		_cachy_config=y
		_cpusched=cachyos
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use bmq; then
		_cachy_config=y
		_cpusched=bmq
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use bore; then
		_cachy_config=y
		_cpusched=bore
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use deckify; then
		_cachy_config=y
		_cpusched=cachyos
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use eevdf; then
		_cachy_config=y
		_cpusched=eevdf
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use hardened; then
		_cachy_config=y
		_cpusched=hardened
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=madvise
	elif use rt-bore; then
		_cachy_config=y
		_cpusched=rt-bore
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use sched-ext; then
		_cachy_config=y
		_cpusched=sched-ext
		_HZ_ticks=1000
		_tickrate=full
		_preempt=full
		_hugepage=always
	elif use server; then
		_cachy_config=
		_cpusched=eevdf
		_HZ_ticks=300
		_tickrate=idle
		_preempt=server
		_hugepage=always
	fi

	# _cachy_config
	if [[ -n "${_cachy_config}" ]]; then
		kconf set CACHY
	fi

	# _cpusched
	case "${_cpusched}" in
		cachyos)
			kconf set SCHED_CLASS_EXT
			kconf set SCHED_BORE
			kconf val MIN_BASE_SLICE_NS 1000000
			;;
		bore|hardened)
			kconf set SCHED_BORE
			kconf val MIN_BASE_SLICE_NS 1000000
			;;
		bmq)
			kconf set SCHED_ALT
			kconf set SCHED_BMQ
			;;
		eevdf) ;;
		rt-bore)
			kconf set SCHED_BORE
			kconf val MIN_BASE_SLICE_NS 1000000
			kconf set PREEMPT_COUNT
			kconf set PREEMPTION
			kconf unset PREEMPT_VOLUNTARY
			kconf unset PREEMPT
			kconf unset PREEMPT_NONE
			kconf unset PREEMPT_RT
			kconf unset PREEMPT_DYNAMIC
			kconf set PREEMPT_BUILD
			kconf set PREEMPT_BUILD_AUTO
			kconf set PREEMPT_AUTO
			;;
		sched-ext)
			kconf set SCHED_CLASS_EXT
			;;
		*)
			die "Invalid _cpusched value: ${_cpusched}"
			;;
	esac

	# _HZ_ticks
	case "${_HZ_ticks}" in
		100|250|500|600|625|750|1000)
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

	# _nr_cpus
	kconf val NR_CPUS 320

	# _tickrate
	case "${_tickrate}" in
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
				kconf set PREEMPT_BUILD
				kconf unset PREEMPT_NONE
				kconf unset PREEMPT_VOLUNTARY
				kconf set PREEMPT
				kconf set PREEMPT_COUNT
				kconf set PREEMPTION
				kconf set PREEMPT_DYNAMIC
				;;
			server)
				kconf set PREEMPT_NONE_BUILD
				kconf set PREEMPT_NONE
				kconf unset PREEMPT_VOLUNTARY
				kconf unset PREEMPT
				kconf unset PREEMPTION
				kconf unset PREEMPT_DYNAMIC
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
	kconf mod TCP_CONG_CUBIC
	kconf unset DEFAULT_CUBIC
	kconf set TCP_CONG_BBR
	kconf val DEFAULT_TCP_CONG bbr

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

src_prepare() {
	local PATCHES=(
		# meh, genpatches have no directory
		"${WORKDIR}"/*.patch
		# CachyOS Patches
		$(cachy_get_patches)
	)
	default

	# Localversion
	kconf val LOCALVERSION "-$(cachy_get_version)" > "${T}"/version.config || die

	# CachyOS config as base
	cp "${DISTDIR}/${CONFIG_P}-kernel.config" .config || die

	# Package defaults
	cachy_get_config > "${T}"/cachy-defaults.config || die

	# Gentoo defaults
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

	local merge_configs=(
		"${T}"/version.config
		"${dist_conf_path}"/base.config
		"${T}"/cachy-defaults.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)

	use secureboot && merge_configs+=( "${dist_conf_path}/secureboot.config" )

	kernel-build_merge_configs "${merge_configs[@]}"
}
