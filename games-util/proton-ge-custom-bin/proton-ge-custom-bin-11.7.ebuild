# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit linux-info

MY_PN="GE-Proton"
MY_PV="${PV//./-}"
MY_P="${MY_PN}${MY_PV}"

DESCRIPTION="Custom distribution of Valves Proton with various patches"
HOMEPAGE="https://github.com/GloriousEggroll/proton-ge-custom"

SRC_URI="
	amd64? ( https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${MY_P}/${MY_P}-x86_64.tar.gz )
	arm64? ( https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${MY_P}/${MY_P}-aarch64.tar.gz )
"
S="${WORKDIR}/${MY_P}"

# from dist.LICENSE
LICENSE="LGPL-2.1 ZLIB libpng LGPL-2 OFL-1.1 MIT MPL-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

IUSE="+ntsync"

# this ebuild expects
# the steam runtime
RDEPEND="
	games-util/steam-launcher[steam-runtime(+)]
"

# all prebuilt
QA_PREBUILT="*"

# we will install Proton with this name
# to avoid conflicting with other installs
INST_P="${MY_PN}-Portage"

pkg_setup() {
	if use ntsync; then
		CONFIG_CHECK="~NTSYNC"
		linux-info_pkg_setup
	fi
}

src_unpack() {
	default

	# there should only ever be one here depending on arch
	mv "${WORKDIR}/${MY_P}"* "${WORKDIR}/${MY_P}" || die
}

src_prepare() {
	sed -i -e "s/${MY_P}/${INST_P}/g" compatibilitytool.vdf || die

	default
}

src_install() {
	local compatd="/usr/share/steam/compatibilitytools.d"

	dodir "${compatd}"

	# mv to preserve mode
	mv "${WORKDIR}/${MY_P}" "${ED}/${compatd}/${INST_P}" || die
	fowners -R root:root "${compatd}/${INST_P}"

	# user_settings.py
	insinto "/etc/proton/${INST_P}"
	doins "${FILESDIR}/user_settings.py"
	dosym -r "/etc/proton/${INST_P}/user_settings.py" "${compatd}/${INST_P}/user_settings.py"

	# ntsync
	if use ntsync; then
		insinto /etc/modules-load.d
		newins - ntsync.conf <<-EOF
		ntsync
		EOF

		insinto /etc/security/limits.d
		newins - 26-steam-nofile.conf <<-EOF
		*               hard    nofile             524288
		EOF
	fi
}

pkg_postinst() {
	elog "user_settings.py was installed to /etc/proton/${INST_P}/user_settings.py"
}
