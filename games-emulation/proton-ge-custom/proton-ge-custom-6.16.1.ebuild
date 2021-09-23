# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV="$(ver_cut 1-2)-GE-$(ver_cut 3)"

DESCRIPTION="Compatibility tool for Steam Play based on Wine and additional components"
HOMEPAGE="https://github.com/GloriousEggroll/proton-ge-custom"
SRC_URI="https://github.com/GloriousEggroll/proton-ge-custom/archive/refs/tags/${MY_PV}.tar.gz"

LICENSE="All rights reserved"
SLOT="6.16"
KEYWORDS="~amd64 ~x86"

#wine-staging might need these flags idk [png,ldap,ssl,openal,v4l,pulseaudio,alsa,jpeg,xcomposite,xinerama,opencl,vaapi,themes,gstreamer,vulkan,cups,samba,dos]
DEPEND="app-emulation/winetricks
		app-emulation/wine-staging
		dev-util/vulkan-headers
		media-libs/vulkan-loader"
RDEPEND="${DEPEND}"
BDEPEND="app-emulation/vagrant[virtualbox]
		app-emulation/virtualbox[lvm]"

src_prepare() {
	default
	exec ./patches/protonprep.sh
}

scr_compile() {
	build
}
