# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

COMMIT="f655d12ae3ef168e9521ba87a2a1bd032fae6001"

DESCRIPTION="Steam session for games-util/gamescope-session"
HOMEPAGE="https://github.com/bazzite-org/gamescope-session-steam"
SRC_URI="https://github.com/bazzite-org/gamescope-session-steam/archive/${COMMIT}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# I'll assume people installing this
# have the steam overlay enabled
RDEPEND="
	games-util/gamescope-session
	games-util/steam-launcher
"

PATCHES=( "${FILESDIR}/gentoo.patch" )

src_install() {
	dobin \
		usr/bin/jupiter-biosupdate \
		usr/bin/steam-http-loader \
		usr/bin/steamos-select-branch \
		usr/bin/steamos-session-select \
		usr/bin/steamos-update

	# this gives "QA Notice: The ebuild is installing to one or more unexpected directories"
	# ... but we need them here
	exeinto /usr/bin/steamos-polkit-helpers
	doexe \
		usr/bin/steamos-polkit-helpers/jupiter-biosupdate \
		usr/bin/steamos-polkit-helpers/steamos-select-branch \
		usr/bin/steamos-polkit-helpers/steamos-update

	domenu usr/share/applications/gamescope-mimeapps.list
	domenu usr/share/applications/steam_http_loader.desktop

	insinto /usr/share/gamescope-session-plus/sessions.d
	doins usr/share/gamescope-session-plus/sessions.d/steam

	insinto /usr/share/polkit-1/actions
	doins usr/share/polkit-1/actions/org.chimeraos.update.policy

	insinto /usr/share/wayland-sessions
	doins usr/share/wayland-sessions/gamescope-session-steam.desktop

	dodoc LICENSE
}
