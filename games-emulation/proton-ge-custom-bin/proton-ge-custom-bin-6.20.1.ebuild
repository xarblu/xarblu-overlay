# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-build

MY_PV="$(ver_cut 1-2)-GE-$(ver_cut 3)"
MY_P="Proton-${MY_PV}"

DESCRIPTION="Compatibility tool for Steam Play based on Wine and additional components"
HOMEPAGE="https://github.com/GloriousEggroll/proton-ge-custom"
SRC_URI="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${MY_PV}/${MY_P}.tar.gz"

LICENSE="All rights reserved"
SLOT="6.20"
KEYWORDS="~amd64"

IUSE="gnome kde winetricks"

DEPEND="gnome? ( gnome-extra/zenity )
		kde? ( kde-apps/kdialog )
		winetricks? ( app-emulation/winetricks )
		dev-util/vulkan-headers
		media-libs/vulkan-loader:=[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_unpack() {
	default

	#Portage complains that that ${S} is missing so we'll just create a dummy here
	mkdir -p ${S}
}

src_install() {
	dodir /usr/share/steam/compatibilitytools.d
	cp -r "${WORKDIR}/${MY_P}" "${ED}"/usr/share/steam/compatibilitytools.d || die "Copying files failed!"
}
