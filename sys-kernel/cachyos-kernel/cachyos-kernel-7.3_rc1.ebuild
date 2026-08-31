# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034,SC2155

EAPI=8

# https://distfiles.gentoo.org/pub/proj/dist-kernel/patchsets/
GENTOO_PATCHSET=linux-gentoo-patches-7.1.9
# https://github.com/gentoo/gentoo-kernel-config
GENTOO_CONFIG_VER=g19
# https://github.com/CachyOS/linux-cachyos
CACHY_CONFIG_COMMIT=00baa5f3c9d467a1a4ff525ef546c21357c50257
# https://github.com/CachyOS/kernel-patches
CACHY_PATCH_COMMIT=687267281f5315be8c9c913858841d603cc2b9c1
# bcachefs backports version
# https://github.com/koverstreet/bcachefs-tools
# https://github.com/xarblu/bcachefs-patches
BCACHEFS_VER=1.39.5_pre20260830174713
# cachyos tarball release
# https://github.com/CachyOS/linux
CACHY_TAR_REL=2

# available flavours
#CACHY_FLAVOURS="cachyos bmq bore deckify eevdf rt-bore server"
CACHY_FLAVOURS="cachyos"

# patches
CACHY_PATCH_SPECS=(
	# flavours
	#bmq:sched/0001-prjc-cachy.patch
	#bore:sched/0001-bore-cachy.patch
	#deckify:misc/0001-acpi-call.patch
	#deckify:misc/0001-handheld.patch
	#deckify:sched/0001-bore-cachy.patch
	#rt-bore:sched/0001-bore-cachy.patch
	#rt-bore:misc/0001-rt-i915.patch
	# other scheds
	#muqss:sched/0001-muqss-cachy.patch
	# clang
	clang:misc/dkms-clang.patch
)

case "${PV}" in
	*_pre*|*_rc*) ;;
	*) KEYWORDS="~amd64" ;;
esac

inherit cachyos-kernel-build
