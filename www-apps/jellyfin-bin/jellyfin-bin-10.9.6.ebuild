# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit pax-utils systemd tmpfiles

DESCRIPTION="Jellyfin puts you in control of managing and streaming your media"
HOMEPAGE="https://jellyfin.org/"
LICENSE="GPL-2"
SLOT="0"
RESTRICT="mirror test"

IUSE="intro-skipper +vendored-ffmpeg"

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
	S="${WORKDIR}/${MY_PN}"
fi

src_uris() {
	local baseuri="https://repo.jellyfin.org/files/server/linux"
	case "${TYPE}" in
		stable) baseuri+="/${TYPE}/v${MY_PV}";;
		unstable) baseuri+="/${TYPE}/${MY_PV}";;
	esac
	for arch in arm64 amd64; do
		SRC_URI+="${arch}? ( "
		for libc in glibc musl; do
			SRC_URI+="elibc_${libc}? ( "
			if [[ "${libc}" == "glibc" ]]; then
				SRC_URI+="${baseuri}/${arch}/${MY_PN}_${MY_PV}-${arch}.tar.gz"
			else
				SRC_URI+="${baseuri}/${arch}-${libc}/${MY_PN}_${MY_PV}-${arch}-${libc}.tar.gz"
			fi
			SRC_URI+=" ) "
		done
		SRC_URI+=" ) "
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
	!vendored-ffmpeg? (
		media-video/ffmpeg[vpx,x264]
		intro-skipper? ( media-video/ffmpeg[chromaprint] )
	)
	|| ( sys-libs/glibc sys-libs/musl )
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
	# add intro-skipper plugin to index.html
	# as per https://github.com/jumoog/intro-skipper/blob/10.9/v0.2.0.9/ConfusedPolarBear.Plugin.IntroSkipper/Plugin.cs#L401
	if use intro-skipper; then
		einfo "Patching index.html due to USE=\"intro-skipper\""
		sed -i -e "s|</head>|<script src=\"configurationpage?name=skip-intro-button.js\"></script>&|" \
			"${S}/jellyfin-web/index.html" || die "Failed modifying index.html"
	fi

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

	if use intro-skipper; then
		einfo ""
		einfo "USE='intro-skipper' only handles the web-injection."
		einfo "To setup the rest of the plugin refer to"
		einfo "https://github.com/jumoog/intro-skipper"
		einfo ""
	fi
}
