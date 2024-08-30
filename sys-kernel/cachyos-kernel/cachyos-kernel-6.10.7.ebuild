# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

inherit kernel-build

MY_P=linux-${PV%.*}

# https://dev.gentoo.org/~mpagano/genpatches/kernels.html
GENPATCHES_P=genpatches-${PV%.*}-$(( ${PV##*.} + 3 ))
# https://github.com/projg2/gentoo-kernel-config
GENTOO_CONFIG_VER=g13
# https://github.com/CachyOS/linux-cachyos
CONFIG_COMMIT="947f6953b873a4dffb1f452ed744d9c28f12d60e"
CONFIG_PV="${PV}-${CONFIG_COMMIT::8}"
CONFIG_P="${PN}-${CONFIG_PV}"
# https://github.com/CachyOS/kernel-patches
PATCH_COMMIT="6df1ab94e174708e3bd6fc5b7ba1f01a7da8c714"
PATCH_PV="${PV}-${PATCH_COMMIT::8}"
PATCH_P="${PN}-${PATCH_PV}"

# array of patches in format
# <use>:<path/to.patch>
# special use - always applies patch
# applied in this order
CACHY_PATCH_SPECS=(
	-:all/0001-cachyos-base-all.patch
	cachyos:sched/0001-sched-ext.patch
	sched-ext:sched/0001-sched-ext.patch
	cachyos:sched/0001-bore-cachy-ext.patch
	bore:sched/0001-bore-cachy.patch
	hardened:sched/0001-bore-cachy.patch
	rt:misc/0001-rt.patch
	rt-bore:misc/0001-rt.patch
	rt-bore:sched/0001-bore-cachy-rt.patch
	hardened:misc/0001-hardened.patch
	echo:sched/0001-echo-cachy.patch
	bmq:sched/0001-prjc-cachy.patch
	pds:sched/0001-prjc-cachy.patch
)

# CPU schdulers supported by cachyos-patches
# there are more options but these are the ones from CachyOS/linux-cachyos
CPU_SCHED="cachyos bore rt rt-bore sched-ext eevdf echo bmq pds hardened"

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

# get the "cachy name" of the kernel
# as in CachyOS/linux-cachyos repo
cachy_get_version() {
	local sched
	for sched in ${CPU_SCHED}; do
		if use "${sched}"; then
			if [[ "${sched}" == "cachyos" ]]; then
				echo "linux-cachyos" || die
			else
				echo "linux-cachyos-${sched}" || die
			fi
			return
		fi
	done
}

# get the patches based on sched choice
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
	# _config_cachy
	kconf set CACHY
	# _cpusched
	if use cachyos || use sched-ext; then
		kconf set SCHED_CLASS_EXT
	fi
	if use cachyos || use bore || use rt-bore || use hardened; then
		kconf set SCHED_BORE
		kconf val MIN_BASE_SLICE_NS 1000000
	fi
	if use rt || use rt-bore; then
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
