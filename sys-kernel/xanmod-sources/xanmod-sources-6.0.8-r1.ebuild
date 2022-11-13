# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="8"
XANMOD_VERSION="1"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"
K_NODRYRUN="1" # fails on 2910_bfp-mark-get-entry-ip-as--maybe-unused.patch

inherit kernel-2
detect_version

DESCRIPTION="Full XanMod sources including the Gentoo patchset"
HOMEPAGE="https://xanmod.org"
LICENSE+=" CDDL"
KEYWORDS="~amd64"
XANMOD_URI="https://github.com/xanmod/linux/releases/download/"
SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	${XANMOD_URI}/${OKV}-xanmod${XANMOD_VERSION}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz
	${GENPATCHES_URI}
"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""
	UNIPATCH_LIST="${UNIPATCH_LIST} ${DISTDIR}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz"
	UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1*_linux-${KV_MAJOR}.${KV_MINOR}.*.patch"
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "MICROCODES"
	elog "xanmod-sources should be used with updated microcodes"
	elog "Read https://wiki.gentoo.org/wiki/Microcode"
	kernel-2_pkg_postinst
}
