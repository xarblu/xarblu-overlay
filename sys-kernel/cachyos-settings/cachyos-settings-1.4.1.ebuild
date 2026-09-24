# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

inherit udev tmpfiles systemd

DESCRIPTION="Configuration files and tweaks from CachyOS"
HOMEPAGE="https://github.com/CachyOS/CachyOS-Settings"
SRC_URI="https://github.com/CachyOS/CachyOS-Settings/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/CachyOS-Settings-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd wifi zram"
REQUIRED_USE="zram? ( systemd ) wifi? ( systemd )"

RDEPEND="
	app-shells/bash
	sys-apps/hdparm
	sys-apps/pciutils
	sys-process/procps
	virtual/udev
	wifi? ( net-wireless/iw )
	zram? (
		sys-apps/zram-generator
		app-arch/zstd
	)
"

src_prepare() {
	default

	# move to more FHS appropriate /usr/libexec
	mkdir -p usr/libexec || die
	mv usr/lib{,exec}/iw-set-regdomain || die
	sed -i -e '/^ExecStart=/s/lib/libexec/' usr/lib/systemd/system/cachyos-iw-set-regdomain.service || die
}

src_install() {
	# subshell to keep globstar contained
	(
		shopt -s globstar

		for file in **; do
			# skip dirs
			[[ -f "${file}" ]] || continue

			case "${file}" in
				# === skipped ===
				# points to CachyOS/Arch resources (servers, wiki, etc.)
				usr/lib/systemd/timesyncd.conf.d/10-timesyncd.conf) ;&
				usr/bin/cachyos-bugreport.sh) ;&
				usr/bin/paste-cachyos) ;&
				etc/debuginfod/cachyos.urls) ;&
				usr/share/glib-2.0/schemas/*) ;&
				# repo metadata
				CODE_OF_CONDUCT.md) ;&
				CONTRIBUTING.md) ;&
				LICENSE.md) ;&
				README.md) ;&
				# maybe behind USE=lua?
				usr/bin/topmem) ;&
				# maybe behind USE=systemd?
				usr/lib/NetworkManager/conf.d/dns.conf) ;&
				# misc unneeded
				usr/bin/sbctl-batch-sign)
					continue
					;;

				# === conditionally skipped ===
				# USE=zram
				usr/lib/systemd/zram-generator.conf) ;&
				usr/lib/udev/rules.d/30-zram.rules)
					use zram || continue
					;;&

				# USE=systemd
				# calls systemd-inhibit
				usr/bin/game-performance) ;&
				# calls journalctl
				usr/bin/kerver)
					use systemd || continue
					;;&

				# USE=wifi
				usr/lib/systemd/system/cachyos-iw-set-regdomain.path) ;&
				usr/lib/systemd/system/cachyos-iw-set-regdomain.service) ;&
				usr/lib/udev/rules.d/85-iw-regulatory.rules) ;&
				usr/libexec/iw-set-regdomain)
					use wifi || continue
					;;&

				# === install ===
				# systemd units
				usr/lib/systemd/system/*.{service,path})
					use systemd || continue

					einfo "Installing systemd unit: ${file@Q}"
					systemd_dounit "${file}"
					;;

				# udev rules
				usr/lib/udev/rules.d/*)
					einfo "Installing udev rules: ${file@Q}"
					udev_dorules "${file}"
					;;

				# executables
				usr/bin/*)
					einfo "Installing executable: ${file@Q}"
					dobin "${file}"
					;;

				# libexec
				usr/libexec/iw-set-regdomain)
					einfo "Installing libexec executable: ${file@Q}"
					exeinto /usr/libexec
					doexe "${file}"
					;;

				# regular files
				*)
					einfo "Installing regular file: ${file@Q}"
					insinto "${file%/*}"
					doins "${file}"
					;;
			esac
		done
	)
}

pkg_postinst() {
	udev_reload
	tmpfiles_process {coredump,thp-shrinker,thp}.conf
}

pkg_postrm() {
	udev_reload
}
