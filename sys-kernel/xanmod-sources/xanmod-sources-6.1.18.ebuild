# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="23"
XANMOD_VERSION="1"
PRJC_VER="6.1"
PRJC_REV="4"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"
K_NODRYRUN="1"

IUSE="extra-patches project-c"

inherit kernel-2
detect_version

DESCRIPTION="Full XanMod sources including the Gentoo patchset"
HOMEPAGE="https://xanmod.org"
KEYWORDS="~amd64"
XANMOD_URI="https://github.com/xanmod/linux/releases/download/"

prjc_get() {
	local PRJC_URI="https://gitlab.com/alfredchen/projectc/-/raw/master/${PRJC_VER}"
	local PRJC_FILE="prjc_v${PRJC_VER}-r${PRJC_REV}.patch"
	local PRJC_GLUE="${FILESDIR}/5501-6.1.12-prjc-glue.patch"
	case $1 in
		license)
			echo -n "GPL-3"
			;;
		src)
			echo -n "project-c? ( ${PRJC_URI}/${PRJC_FILE} -> 5500-${PRJC_FILE} )"
			;;
		patch)
			echo -n "${DISTDIR}/5500-${PRJC_FILE} ${PRJC_GLUE}"
			;;
	esac
}

LICENSE+=" CDDL $(prjc_get license)"

SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	${XANMOD_URI}/${OKV}-xanmod${XANMOD_VERSION}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz
	$(prjc_get src)
	${GENPATCHES_URI}
"

EXTRA_PATCHES="
	${FILESDIR}/5511-6.1.0-hid-nintendo-faceswap.patch
"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""
	UNIPATCH_LIST="${UNIPATCH_LIST} ${DISTDIR}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz"
	if use extra-patches; then
		UNIPATCH_LIST="${UNIPATCH_LIST} ${EXTRA_PATCHES}"
	fi
	if use project-c; then
		UNIPATCH_LIST="${UNIPATCH_LIST} $(prjc_get patch)"
	fi
	UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1*_linux-${KV_MAJOR}.${KV_MINOR}.*.patch"
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "MICROCODES"
	elog "xanmod-sources should be used with updated microcodes"
	elog "Read https://wiki.gentoo.org/wiki/Microcode"
	kernel-2_pkg_postinst
}
