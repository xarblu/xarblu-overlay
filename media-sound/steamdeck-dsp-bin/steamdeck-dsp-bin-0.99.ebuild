# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Steamdeck Audio Processing"
HOMEPAGE="https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/"
SRC_URI="https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steamdeck-dsp-${PV}-1-any.pkg.tar.zst"
S="${WORKDIR}"

# the package itself just says "Proprietary"
# but the sof firware is BSD-3
LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	media-libs/alsa-ucm-conf
	media-libs/lv2
	media-video/pipewire[lv2]
	media-video/wireplumber
"

QA_PREBUILT="*"

src_unpack() {
	# apparently default unpack doesn't like *.pkg.tar.zst
	unpacker
}

src_install() {
	insinto /usr/lib/firmware/
	doins -r usr/lib/firmware/amd

	insinto /usr/"$(get_libdir)"/lv2
	doins -r usr/lib/lv2/*

	insinto /usr/share/alsa/ucm2/conf.d
	doins -r usr/share/alsa/ucm2/conf.d/sof-nau8821-max

	insinto /usr/share/pipewire/hardware-profiles
	doins -r usr/share/pipewire/hardware-profiles/*

	insinto /usr/share/wireplumber/hardware-profiles
	doins -r usr/share/wireplumber/hardware-profiles/*
}
