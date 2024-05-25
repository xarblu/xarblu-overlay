# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker linux-info

MY_PV="${PV//_/-}"

DESCRIPTION="The Mullvad VPN client app for desktop"
HOMEPAGE="https://mullvad.net"
SRC_URI="
	amd64? ( https://github.com/mullvad/mullvadvpn-app/releases/download/${MY_PV}/MullvadVPN-${MY_PV}_amd64.deb )
	arm64? ( https://github.com/mullvad/mullvadvpn-app/releases/download/${MY_PV}/MullvadVPN-${MY_PV}_arm64.deb )
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

DEPEND="
	net-misc/iputils
	x11-libs/libnotify
	dev-libs/libappindicator:3
	dev-libs/nss
"
RDEPEND="${DEPEND}"
BDEPENDS="
	$(unpacker_src_uri_depends)
"

# openvpn needs CONFIG_TUN
# wireguard needs CONFIG_WIREGUARD
CONFIG_CHECK="
	~TUN
	~WIREGUARD
"

# binary package, everything is prebuilt
QA_PREBUILT="*"

src_unpack() {
	mkdir -p "${S}" || die "mkdir failed"
	cd "${S}" || die "cd failed"
	unpacker ${A}
}

src_prepare() {
	# Fix zsh-completion path
	mv usr/{local,}/share/zsh
	rm -r  usr/local || die "rm failed"

	# don't install "docs" (they're just deb changelogs)
	rm -r usr/share/doc || die "rm failed"

	eapply_user
}

src_install() {
	# 'install' messes with permissions so just cp here
	cp -r "${S}"/* "${ED}"

	# Wrapper for the GUI
	newbin "${FILESDIR}/wrapper.sh" mullvad-gui

	# openrc init
	doinitd "${FILESDIR}/mullvad-daemon.rc"
	doinitd "${FILESDIR}/mullvad-early-boot-blocking.rc"
}
