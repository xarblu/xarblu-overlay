# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034,SC2155

EAPI=8

# see https://github.com/CachyOS/linux-cachyos/blob/master/linux-cachyos/PKGBUILD
# "validpgpkeys" array
SEC_KEYS_VALIDPGPKEYS=(
	E18447AC260021D31F3FF6C4C8A2A4774B8B63C4:enaim:ubuntu
	E8B9AA39F054E30E8290D492C3C4820857F654FE:pjung:ubuntu
)

inherit sec-keys

DESCRIPTION="OpenPGP keys used by the CachyOS maintainers"
HOMEPAGE="https://cachyos.org/"

KEYWORDS="~amd64"
