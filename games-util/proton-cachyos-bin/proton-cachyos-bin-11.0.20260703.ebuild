# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit linux-info

MY_PN="proton-cachyos"
MY_PV="$(ver_cut 1-2)-$(ver_cut 3)"
MY_P="${MY_PN}-${MY_PV}-slr"

DESCRIPTION="Custom distribution of Valves Proton from CachyOS"
HOMEPAGE="https://github.com/CachyOS/proton-cachyos"

setup_globals() {
	# if all these cpu flags are present fetch the v3 version
	# (see https://en.wikipedia.org/wiki/X86-64#Microarchitecture_levels
	# and /var/db/repos/gentoo/profiles/arch/amd64/use.mask)
	local -a cpu_flags_x86_64_v3=(
		# v2
		cpu_flags_x86_popcnt
		cpu_flags_x86_sse3
		cpu_flags_x86_sse4_1
		cpu_flags_x86_sse4_2
		cpu_flags_x86_ssse3
		# v3
		cpu_flags_x86_avx
		cpu_flags_x86_avx2
		cpu_flags_x86_bmi1
		cpu_flags_x86_bmi2
		cpu_flags_x86_f16c
		cpu_flags_x86_fma3
	)

	local base="https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${MY_PV}-slr/${MY_P}"
	local x86_64="${base}-x86_64.tar.xz"
	local x86_64_v3="${base}-x86_64_v3.tar.xz"
	local arm64="${base}-arm64.tar.xz"
	local flag

	IUSE+="amd64 arm64 ${cpu_flags_x86_64_v3[*]}"

	# -- amd64 --
	SRC_URI+="amd64? ("

	# -- x86_64_v3 --
	for flag in "${cpu_flags_x86_64_v3[@]}"; do
		SRC_URI+=" ${flag}? ("
	done

	SRC_URI+=" ${x86_64_v3} "

	for flag in "${cpu_flags_x86_64_v3[@]}"; do
		SRC_URI+=" )"
	done
	# -- x86_64_v3 --

	# -- x86_64 --
	for flag in "${cpu_flags_x86_64_v3[@]}"; do
		SRC_URI+=" !${flag}? ( ${x86_64} )"
	done
	# -- x86_64 --

	SRC_URI+=" )"
	# -- amd64 --

	# -- arm64 --
	SRC_URI+=" arm64? ( ${arm64} )"
	# -- arm64 --
}
setup_globals

S="${WORKDIR}/${MY_P}"

# from dist.LICENSE
LICENSE="LGPL-2.1 ZLIB libpng LGPL-2 OFL-1.1 MIT MPL-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

IUSE+=" +ntsync"

# this ebuild expects
# the steam runtime
RDEPEND="
	games-util/steam-launcher[steam-runtime(+)]
"

# all prebuilt
QA_PREBUILT="*"

# we will install Proton with this name
# to avoid conflicting with other installs
INST_P="${MY_PN}-portage"

pkg_setup() {
	if use ntsync; then
		CONFIG_CHECK="~NTSYNC"
		linux-info_pkg_setup
	fi
}

src_unpack() {
	default

	# normalize name to S
	# there should only ever be 1 archive
	mv "${WORKDIR}/${MY_P}"-* "${S}" || die
}

src_prepare() {
	sed -i -e "s/${MY_PN}-[^\"]*/${INST_P}/g" compatibilitytool.vdf || die

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
		newins - "${PN}-ntsync.conf" <<-EOF
		ntsync
		EOF

		insinto /etc/security/limits.d
		newins - "26-${PN}-steam-nofile.conf" <<-EOF
		*               hard    nofile             524288
		EOF
	fi
}

pkg_postinst() {
	elog "user_settings.py was installed to /etc/proton/${INST_P}/user_settings.py"
}
