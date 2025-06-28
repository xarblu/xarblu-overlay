# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Steamdeck Firmware (from CachyOS)"
HOMEPAGE="https://github.com/CachyOS/CachyOS-Handheld"
SRC_URI="https://github.com/CachyOS/CachyOS-Handheld/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/CachyOS-Handheld-${PV}"

# no idea what license...
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

QA_PREBUILT="
	/usr/lib/firmware/*
"

src_install() {
	insinto /usr/lib/firmware
	doins -r usr/lib/firmware/*
}
