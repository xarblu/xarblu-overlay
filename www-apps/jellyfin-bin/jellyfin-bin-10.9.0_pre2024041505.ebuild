# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit pax-utils systemd tmpfiles

DESCRIPTION="Jellyfin puts you in control of managing and streaming your media"
HOMEPAGE="https://jellyfin.org/"
LICENSE="GPL-2"
SLOT="0"
IUSE="jellyscrub"
RESTRICT="mirror test"

MY_PN="${PN%-bin}"

if [[ "${PV}" == *_pre* ]]; then
	TYPE="unstable"
	MY_PV="${PV#*_pre}"
	# should have -* but that also
	# affects supported arches
	KEYWORDS=""
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
	media-video/ffmpeg[vpx,x264]
	sys-libs/glibc
"
BDEPEND="
	acct-user/jellyfin
"

INST_DIR="/opt/${MY_PN}"
QA_PREBUILT="${INST_DIR#/}/*.so ${INST_DIR#/}/jellyfin ${INST_DIR#/}/createdump"

pkg_pretend() {
	if use jellyscrub; then
		ewarn "If your Jellyfin server uses a baseurl you need to set JF_BASEURL=<baseurl>."
		ewarn "Otherwise the Jellyscrub plugin won't work."
	fi
}

src_prepare() {
	default

	# https://github.com/jellyfin/jellyfin/issues/7471
	# https://github.com/dotnet/runtime/issues/57784
	rm libcoreclrtraceptprovider.so || die
}

src_install() {
	#Add jellyscrub plugin to index.html
	if use jellyscrub; then
		sed -i -e "s|</body>|<script plugin=\"Jellyscrub\" version=\"1.0.0.0\" src=\"${JF_BASEURL#/}/Trickplay/ClientScript\"></script>&|" "${S}/jellyfin-web/index.html" || die "Failed modifying index.html"
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
	newinitd "${FILESDIR}/${MY_PN}.init-r1" "${MY_PN}"
	newconfd "${FILESDIR}/${MY_PN}.confd" "${MY_PN}"
	systemd_dounit "${FILESDIR}/${MY_PN}.service"
}

pkg_postinst() {
	tmpfiles_process jellyfin.conf
}
