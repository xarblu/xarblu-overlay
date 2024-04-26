# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit pax-utils systemd tmpfiles

DESCRIPTION="Jellyfin puts you in control of managing and streaming your media"
HOMEPAGE="https://jellyfin.org/"
LICENSE="GPL-2"
SLOT="0"
RESTRICT="mirror test"

IUSE="+vendored-ffmpeg"

MY_PN="${PN%-bin}"

if [[ "${PV}" == *_pre* ]]; then
	TYPE="unstable"
	MY_PV="${PV#*_pre}"
	# should have -* but that also
	# affects supported arches
	#KEYWORDS=""
	S="${WORKDIR}/${MY_PN}"
else
	TYPE="stable"
	MY_PV="${PV}"
	KEYWORDS="-* ~amd64 ~arm64"
	S="${WORKDIR}/${MY_PN}_${MY_PV}"
fi

src_uris() {
	local baseuri="https://repo.jellyfin.org/files/server/linux"
	for arch in arm64 amd64; do
		case "${TYPE}" in
			stable)
				SRC_URI+="
					${arch}? (
						${baseuri}/${TYPE}/${MY_PV}/${arch}/${MY_PN}_${MY_PV}_${arch}.tar.gz
					)
				"
				;;
			unstable)
				SRC_URI+="
					${arch}? (
						${baseuri}/${TYPE}/${MY_PV}/${arch}/${MY_PN}_${MY_PV}-${arch}.tar.gz
					)
				"
				;;
		esac
	done
}
src_uris

DEPEND="
	acct-user/jellyfin
	media-libs/fontconfig
	sys-libs/zlib
"
RDEPEND="${DEPEND}
	dev-libs/icu
	vendored-ffmpeg? ( media-video/jellyfin-ffmpeg )
	!vendored-ffmpeg? ( media-video/ffmpeg[vpx,x264] )
	sys-libs/glibc
"
BDEPEND="
	acct-user/jellyfin
"

INST_DIR="/opt/${MY_PN}"
QA_PREBUILT="${INST_DIR#/}/*.so ${INST_DIR#/}/jellyfin ${INST_DIR#/}/createdump"

src_prepare() {
	default

	# https://github.com/jellyfin/jellyfin/issues/7471
	# https://github.com/dotnet/runtime/issues/57784
	rm libcoreclrtraceptprovider.so || die
}

src_install() {
	# runtime dirs
	keepdir /var/log/jellyfin
	fowners jellyfin:jellyfin /var/log/jellyfin
	keepdir /etc/jellyfin
	fowners jellyfin:jellyfin /etc/jellyfin
	newtmpfiles - jellyfin.conf <<<"d /var/cache/jellyfin 0775 jellyfin jellyfin -"

	# jellyfin files
	insinto "${INST_DIR}"
	doins -r ./*
	fperms 755 "${INST_DIR}/jellyfin"
	pax-mark -m "${INST_DIR}/jellyfin"

	# services
	local f cmd
	for f in "${FILESDIR}/${MY_PN}".{init-r2,confd-r1,service-r1}; do
		case "${f}" in
			*.init*) cmd="newinitd - ${MY_PN}";;
			*.confd*) cmd="newconfd - ${MY_PN}";;
			*.service*) cmd="systemd_newunit - ${MY_PN}.service";;
			*) die "Don't know how to handle ${f}";;
		esac
		if ! use vendored-ffmpeg; then
			sed -e 's#/usr/lib/jellyfin-ffmpeg/bin/ffmpeg#/usr/bin/ffmpeg#g' \
				"${f}" || die
		else
			cat "${f}" || die
		fi | ${cmd}
	done
}

pkg_postinst() {
	tmpfiles_process jellyfin.conf
}
