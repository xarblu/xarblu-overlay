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
CACHYOS_CONFIG_COMMIT="ef8a4eb271d6251078ee698b5e9026b4ea7fb35e"
# https://github.com/CachyOS/kernel-patches
CACHYOS_PATCH_COMMIT="97cbea2e6fc06cc4cb48710e444c965a1db8e4d6"
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
	?? ( ${CPU_SCHED//+/} )
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

cachy_get_version() {
	if use cachyos; then
		echo "linux-cachyos"
	fi
	if use bore; then
		echo "linux-cachyos-bore"
	fi
	if use rt; then
		echo "linux-cachyos-rt"
	fi
	if use rt-bore; then
		echo "linux-cachyos-rt-bore"
	fi
	if use hardened; then
		echo "linux-cachyos-hardened"
	fi
	if use sched-ext; then
		echo "linux-cachyos-sched-ext"
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
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die

	# CachyOS config as base
	cp "${WORKDIR}/linux-cachyos-${CACHYOS_CONFIG_COMMIT}/${myversion}/config" \
		.config || die

	# Package defaults
	# Enable cachy tweaks and BORE (if included)
	echo "CONFIG_CACHY=y" > "${T}"/cachy-defaults.config || die
	if use cachyos || use bore || use rt-bore || use hardened; then
		echo "CONFIG_SCHED_BORE=y" >> "${T}/cachy-defaults.config" || die
	fi

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
