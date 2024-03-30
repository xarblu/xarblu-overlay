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
GENTOO_CONFIG_VER=g11
# https://github.com/CachyOS/linux-cachyos
CACHYOS_CONFIG_COMMIT="bbb2e960cd5639f958c8393ead0e0eabb972267d"
# https://github.com/CachyOS/kernel-patches
CACHYOS_PATCH_COMMIT="9070d001c8cf2ce62a33028ab9881d80aeec6abf"

# CPU schdulers supported by cachyos-patches
# there are more options but these are the ones from CachyOS/linux-cachyos
CPU_SCHED="cachyos bore rt rt-bore hardened sched-ext eevdf echo"

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

cachy_get_patches() {
	local cachy_patch="${WORKDIR}/kernel-patches-${CACHYOS_PATCH_COMMIT}/${PV%.*}"

	# unconditional base patches
	echo "${cachy_patch}/all/0001-cachyos-base-all.patch" || die

	# scheduler patches
	if use cachyos || use sched-ext; then
		echo "${cachy_patch}/sched/0001-sched-ext.patch" || die
	fi
	if use cachyos || use bore || use hardened; then
		echo "${cachy_patch}/sched/0001-bore-cachy.patch" || die
	fi
	if use rt || use rt-bore; then
		echo "${cachy_patch}/misc/0001-rt.patch" || die
	fi
	if use rt-bore; then
		echo "${cachy_patch}/sched/0001-bore-cachy-rt.patch" || die
	fi
	if use hardened; then
		echo "${cachy_patch}/misc/0001-hardened.patch" || die
	fi
	if use echo; then
		echo "${cachy_patch}/sched/0001-echo-cachy.patch" || die
	fi
}

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

# cpusched based config defaults
cachy_get_cpusched_config() {
	if use cachyos || use sched-ext; then
		echo "CONFIG_SCHED_CLASS_EXT=y" || die
	fi
	if use cachyos || use bore || use rt-bore || use hardened; then
		echo "CONFIG_SCHED_BORE=y" || die
	fi
	if use rt || use rt-bore; then
		echo "CONFIG_PREEMPT_COUNT=y" || die
		echo "CONFIG_PREEMPTION=y" || die
		echo "CONFIG_PREEMPT_VOLUNTARY=y" || die
		echo "CONFIG_PREEMPT=y" || die
		echo "CONFIG_PREEMPT_NONE=y" || die
		echo "CONFIG_PREEMPT_RT=y" || die
		echo "CONFIG_PREEMPT_DYNAMIC=y" || die
		echo "CONFIG_PREEMPT_BUILD=y" || die
	fi
	if use echo; then
		echo "CONFIG_ECHO_SCHED=y" || die
	fi
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
	local myversion="$(cachy_get_version)"
	echo "CONFIG_LOCALVERSION=\"-${myversion}\"" > "${T}"/version.config || die

	# CachyOS config as base
	cp "${WORKDIR}/linux-cachyos-${CACHYOS_CONFIG_COMMIT}/${myversion}/config" \
		.config || die

	# Package defaults
	# enable cachy tweaks
	echo "CONFIG_CACHY=y" > "${T}"/cachy-defaults.config || die
	# enable config items based on CPU_SCHED choice
	cachy_get_cpusched_config >> "${T}"/cachy-defaults.config || die

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
