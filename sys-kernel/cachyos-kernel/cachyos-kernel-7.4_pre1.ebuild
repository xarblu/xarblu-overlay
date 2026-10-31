# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034,SC2155

EAPI=8

# https://distfiles.gentoo.org/pub/proj/dist-kernel/patchsets/
GENTOO_PATCHSET=linux-gentoo-patches-7.3.1
# https://github.com/gentoo/gentoo-kernel-config
GENTOO_CONFIG_VER=g19
# https://github.com/CachyOS/linux-cachyos
CACHY_CONFIG_COMMIT=343523fffa2cbfd37e37a04e793d641cbd0fe975
# https://github.com/CachyOS/kernel-patches
CACHY_PATCH_COMMIT=542948508e7098b6482d8269bc1097733dd27399
# bcachefs backports version
# https://github.com/koverstreet/bcachefs-tools
# https://github.com/xarblu/bcachefs-patches
BCACHEFS_VER=1.39.8_pre20261028230352
# cachyos tarball release
# https://github.com/CachyOS/linux
CACHY_TAR_REL=1

# available flavours
# all: cachyos bmq bore deckify eevdf rt-bore server
CACHY_FLAVOURS="cachyos bmq bore deckify eevdf rt-bore server"

# patches
CACHY_PATCH_SPECS=(
	# flavours
	bmq:sched/0001-prjc-cachy.patch
	bore:sched/0001-bore-cachy.patch
	deckify:misc/0001-acpi-call.patch
	deckify:misc/0001-handheld.patch
	deckify:sched/0001-bore-cachy.patch
	rt-bore:sched/0001-bore-cachy.patch
	rt-bore:misc/0001-rt-i915.patch
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

src_prepare() {
	cachyos-kernel-build_src_prepare

	# 7.4_preX is not actually 7.4 but the bcachefs
	# macros treat it as such
	use bcachefs && eapply "${FILESDIR}/7.4_preX-revert-7.4-api.patch"
}
