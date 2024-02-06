# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

# for kernel-install.eclass install path
KV_LOCALVERSION="-cachyos"

inherit kernel-build

MY_P=linux-${PV%.*}

# https://dev.gentoo.org/~mpagano/genpatches/kernels.html
GENPATCHES_P=genpatches-${PV%.*}-$(( ${PV##*.} + 4 ))
# https://github.com/projg2/gentoo-kernel-config
GENTOO_CONFIG_VER=g11
# https://github.com/CachyOS/linux-cachyos
CACHYOS_CONFIG_COMMIT="38718bddbc3c8c82259ae939b1f343b8912b7b4b"
# https://github.com/CachyOS/kernel-patches
CACHYOS_PATCH_COMMIT="240096ea22a186f7c0896f9c298f3bab1e91e8ae"
# CPU schdulers supported by cachyos-patches
CPU_SCHED="+cachyos bore rt rt-bore hardened sched-ext"

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
IUSE="debug ${CPU_SCHED}"
REQUIRED_USE="
	^^ ( ${CPU_SCHED//+/} )
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
	echo "${cachy_patch}/all/0001-cachyos-base-all.patch"
	echo "${cachy_patch}/misc/0001-Add-extra-version-CachyOS.patch"

	# scheduler patches
	if use cachyos; then
		echo "${cachy_patch}/sched/0001-sched-ext.patch"
		echo "${cachy_patch}/sched/0001-bore-cachy.patch"
	fi
	if use bore; then
		echo "${cachy_patch}/sched/0001-bore-cachy.patch"
	fi
	if use rt; then
		echo "${cachy_patch}/misc/0001-rt.patch"
	fi
	if use rt-bore; then
		echo "${cachy_patch}/misc/0001-rt.patch"
		echo "${cachy_patch}/sched/0001-bore-cachy-rt.patch"
	fi
	if use hardened; then
		echo "${cachy_patch}/sched/0001-bore-cachy.patch"
		echo "${cachy_patch}/misc/0001-hardened.patch"
	fi
	if use sched-ext; then
		echo "${cachy_patch}/sched/0001-sched-ext.patch"
	fi
}

cachy_get_config() {
	local cachy_config="${WORKDIR}/linux-cachyos-${CACHYOS_CONFIG_COMMIT}"
	if use cachyos; then
		echo "${cachy_config}/linux-cachyos/config"
	fi
	if use bore; then
		echo "${cachy_config}/linux-cachyos-bore/config"
	fi
	if use rt; then
		echo "${cachy_config}/linux-cachyos-rt/config"
	fi
	if use rt-bore; then
		echo "${cachy_config}/linux-cachyos-rt-bore/config"
	fi
	if use hardened; then
		echo "${cachy_config}/linux-cachyos-hardened/config"
	fi
	if use sched-ext; then
		echo "${cachy_config}/linux-cachyos-sched-ext/config"
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

	# Base CachyOS Config
	cp "$(cachy_get_config)" .config || die

	# default enable cachy tweaks
	echo "CONFIG_CACHY=y" > "${T}"/cachy-defaults.config || die

	# default enable BORE when included
	if use cachyos || use bore || use rt-bore || use hardened; then
		echo "CONFIG_SCHED_BORE=y" >> "${T}/cachy-defaults.config" || die
	fi

	# Gentoo Defaults
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

	local merge_configs=(
		"${dist_conf_path}"/base.config
		"${T}"/cachy-defaults.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)

	use secureboot && merge_configs+=( "${dist_conf_path}/secureboot.config" )

	kernel-build_merge_configs "${merge_configs[@]}"
}
