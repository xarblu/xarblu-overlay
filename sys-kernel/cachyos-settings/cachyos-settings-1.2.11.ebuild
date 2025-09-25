# Copyright 2025 Gentoo Authors
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
IUSE="systemd zram"
REQUIRED_USE="zram? ( systemd )"

RDEPEND="
	app-shells/bash
	sys-apps/hdparm
	sys-apps/pciutils
	sys-process/procps
	virtual/udev
	zram? (
		sys-apps/zram-generator
		app-arch/zstd
	)
"

src_install() {
	insinto /etc/security/limits.d/
	doins etc/security/limits.d/20-audio.conf

	# only install script that make sense
	dobin usr/bin/{dlss-swapper,dlss-swapper-dll,game-performance,kerver,pci-latency,zink-run}

	insinto /usr/lib/modprobe.d
	doins usr/lib/modprobe.d/{amdgpu,blacklist,nvidia}.conf

	insinto /usr/lib/modules-load.d
	doins usr/lib/modules-load.d/{10-uinput,ntsync}.conf

	insinto /usr/lib/sysctl.d
	doins usr/lib/sysctl.d/{99-bore-scheduler,99-cachyos-settings}.conf

	if use systemd; then
		# can't use systemd_get_utildir directly
		# as it includes EPREFIX
		local systemd_utildir
		systemd_utildir="$(systemd_get_utildir)"
		systemd_utildir="${systemd_utildir#"${EPREFIX}"}"

		insinto "${systemd_utildir}/journald.conf.d"
		doins usr/lib/systemd/journald.conf.d/00-journal-size.conf

		insinto "${systemd_utildir}/system.conf.d"
		doins usr/lib/systemd/system.conf.d/{00-timeout,10-limits}.conf

		# units
		systemd_dounit usr/lib/systemd/system/pci-latency.service

		# dropins (doins to preserve names)
		insinto "${systemd_utildir}/system"
		doins -r  usr/lib/systemd/system/{rtkit-daemon,user@}.service.d

		insinto "${systemd_utildir}/user.conf.d"
		doins usr/lib/systemd/user.conf.d/10-limits.conf

		if use zram; then
			insinto "${systemd_utildir}"
			doins usr/lib/systemd/zram-generator.conf
		fi
	fi

	dotmpfiles usr/lib/tmpfiles.d/{coredump,thp-shrinker,thp}.conf

	udev_dorules usr/lib/udev/rules.d/{20-audio-pm,30-zram,40-hpet-permissions,50-sata,60-ioschedulers,69-hdparm,71-nvidia,99-cpu-dma-latency}.rules

	insinto /usr/share/X11/xorg.conf.d
	doins usr/share/X11/xorg.conf.d/20-touchpad.conf
}

pkg_postinst() {
	udev_reload
	tmpfiles_process {coredump,thp-shrinker,thp}.conf
}

pkg_postrm() {
	udev_reload
}
