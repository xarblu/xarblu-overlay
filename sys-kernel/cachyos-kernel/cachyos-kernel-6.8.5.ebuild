# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

inherit kernel-build

MY_P=linux-${PV%.*}

# https://dev.gentoo.org/~mpagano/genpatches/kernels.html
GENPATCHES_P=genpatches-${PV%.*}-$(( ${PV##*.} + 2 ))
# https://github.com/projg2/gentoo-kernel-config
GENTOO_CONFIG_VER=g11
# https://github.com/CachyOS/linux-cachyos
CACHYOS_CONFIG_COMMIT="9d3b8f3955e28a1e76d35874d9c5f8dd1d05623e"
# https://github.com/CachyOS/kernel-patches
CACHYOS_PATCH_COMMIT="b1ffade4e48f01afe3703c0801b35c90d59ab9cc"

# CPU schdulers supported by cachyos-patches
# there are more options but these are the ones from CachyOS/linux-cachyos
CPU_SCHED="cachyos bore rt rt-bore sched-ext eevdf echo bmq pds"

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
	https://github.com/CachyOS/linux-cachyos/archive/${CACHYOS_CONFIG_COMMIT}.tar.gz
		-> cachyos-configs-${CACHYOS_CONFIG_COMMIT}.tar.gz
	https://github.com/CachyOS/kernel-patches/archive/${CACHYOS_PATCH_COMMIT}.tar.gz
		-> cachyos-patches-${CACHYOS_PATCH_COMMIT}.tar.gz
"
S=${WORKDIR}/${MY_P}

KEYWORDS="~amd64"
IUSE="debug ${CPU_SCHED/cachyos/+cachyos}"
REQUIRED_USE="
	^^ ( ${CPU_SCHED} )
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
				die "kconv val requires a value"
			fi
			echo "CONFIG_$2=\"$3\""
			;;
		*)
			die "invalid option $1 for kconf"
			;;
	esac
}

# get the "cachy name" of the kernel
# as in CachyOS/linux-cachyos repo
cachy_get_version() {
	for flag in ${CPU_SCHED}; do
		if use "${flag}"; then
			if use cachyos; then
				echo "linux-cachyos" || die
			else
				echo "linux-cachyos-${flag}" || die
			fi
			return
		fi
	done
}

# get the patches based on sched choice
# WARNING: default "cachyos sched" changes frequently
# usually between bore+sched-ext and just sched-ext
cachy_get_patches() {
	local cachy_patch="${WORKDIR}/kernel-patches-${CACHYOS_PATCH_COMMIT}/${PV%.*}"

	# unconditional base patches
	echo "${cachy_patch}/all/0001-cachyos-base-all.patch" || die

	# scheduler patches
	if use cachyos || use sched-ext; then
		echo "${cachy_patch}/sched/0001-sched-ext.patch" || die
	fi
	if use cachyos; then
		echo "${cachy_patch}/sched/0001-bore-cachy-ext.patch" || die
	fi
	if use bore; then
		echo "${cachy_patch}/sched/0001-bore-cachy.patch" || die
	fi
	if use rt || use rt-bore; then
		echo "${cachy_patch}/misc/0001-rt.patch" || die
	fi
	if use rt-bore; then
		echo "${cachy_patch}/sched/0001-bore-cachy-rt.patch" || die
	fi
	if use echo; then
		echo "${cachy_patch}/sched/0001-echo-cachy.patch" || die
	fi
	if use bmq || use pds; then
		echo "${cachy_patch}/sched/0001-prjc-cachy.patch" || die
	fi
}

# config defaults from Arch PKGBUILD
# sorted the same way as their prepare()
# WARNING: default "cachyos sched" changes frequently
# usually between bore+sched-ext and just sched-ext
cachy_get_config() {
	# _config_cachy
	kconf set CACHY
	# _cpusched
	if use cachyos || use sched-ext; then
		kconf set SCHED_CLASS_EXT
	fi
	if use cachyos || use bore || use rt-bore; then
		kconf set SCHED_BORE
	fi
	if use rt || use rt-bore; then
		kconf set PREEMPT_COUNT
		kconf set PREEMPTION
		kconf unset PREEMPT_VOLUNTARY
		kconf unset PREEMPT
		kconf unset PREEMPT_NONE
		kconf set PREEMPT_RT
		kconf unset PREEMPT_DYNAMIC
		kconf unset PREEMPT_BUILD
	fi
	if use echo; then
		kconf set ECHO_SCHED
	fi
	if use bmq; then
		kconf set SCHED_ALT
		kconf set SCHED_BMQ
	fi
	if use pds; then
		kconf set SCHED_ALT
		kconf set SCHED_PDS
	fi
	# _HZ_ticks
	# ECHO 625, everything else 1000
	if use echo; then
		kconf unset HZ_300
		kconf set HZ_625
		kconf val HZ 625
	else
		kconf unset HZ_300
		kconf set HZ_1000
		kconf val HZ 1000
	fi
	# _nr_cpus
	kconf val NR_CPUS 320
	# _tickrate
	kconf unset HZ_PERIODIC
	kconf unset NO_HZ_IDLE
	kconf unset CONTEXT_TRACKING_FORCE
	kconf set NO_HZ_FULL_NODEF
	kconf set NO_HZ_FULL
	kconf set NO_HZ
	kconf set NO_HZ_COMMON
	kconf set CONTEXT_TRACKING
	# _preempt
	if ! use rt && ! use rt-bore; then
		kconf set PREEMPT_BUILD
		kconf unset PREEMPT_NONE
		kconf unset PREEMPT_VOLUNTARY
		kconf set PREEMPT
		kconf set PREEMPT_COUNT
		kconf set PREEMPTION
		kconf set PREEMPT_DYNAMIC
	fi
	# _cc_harder
	kconf unset CC_OPTIMIZE_FOR_PERFORMANCE
	kconf set CC_OPTIMIZE_FOR_PERFORMANCE_O3
	# _tcp_bbr3
	kconf mod TCP_CONG_CUBIC
	kconf unset DEFAULT_CUBIC
	kconf set TCP_CONG_BBR
	kconf val DEFAULT_TCP_CONG bbr
	# _lru_config
	kconf set LRU_GEN
	kconf set LRU_GEN_ENABLED
	kconf unset LRU_GEN_STATS
	# _vma_config
	kconf set PER_VMA_LOCK
	kconf unset PER_VMA_LOCK_STATS
	# _hugepage
	kconf unset TRANSPARENT_HUGEPAGE_MADVISE
	kconf set TRANSPARENT_HUGEPAGE_ALWAYS
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
	# they're all in sync (besides lts/rc) so use the main linux-cachyos config
	cp "${WORKDIR}/linux-cachyos-${CACHYOS_CONFIG_COMMIT}/linux-cachyos/config" \
		.config || die

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
