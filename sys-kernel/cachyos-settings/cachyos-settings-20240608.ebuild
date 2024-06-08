# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit udev tmpfiles systemd

COMMIT="d11d7af5b722894fa05c6292f1ba336658adc0bd"
DESCRIPTION="Configuration files and tweaks from CachyOS"
HOMEPAGE="https://github.com/CachyOS/CachyOS-Settings"
SRC_URI="https://github.com/CachyOS/CachyOS-Settings/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/CachyOS-Settings-${COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd zram"
REQUIRED_USE="zram? ( systemd )"

DEPEND="
	sys-apps/hdparm
	sys-process/procps
	virtual/udev
	zram? (
		sys-apps/zram-generator
		app-arch/zstd
	)
"
RDEPEND="${DEPEND}"

src_install() {
	insinto /etc/security/limits.d
	doins etc/security/limits.d/*

	insinto /usr/lib/modprobe.d
	doins usr/lib/modprobe.d/*

	insinto /usr/lib/sysctl.d
	doins usr/lib/sysctl.d/*

	insinto /usr/lib/systemd/journald.conf.d
	doins usr/lib/systemd/journald.conf.d/*

	insinto /usr/lib/systemd/system.conf.d
	doins usr/lib/systemd/system.conf.d/*

	# this explicitly doesn't install the
	# .service files because we don't install
	# the cachyos specific scripts
	local dir file unit
	for dir in usr/lib/systemd/system/*.d; do
		unit="${dir##*/}"
		unit="${unit%.d}"
		for file in "${dir}"/*; do
			systemd_install_dropin "${unit}" "${file}"
		done
	done

	insinto /usr/lib/systemd/user.conf.d
	doins usr/lib/systemd/user.conf.d/*

	if use zram; then
		insinto /usr/lib/systemd
		doins usr/lib/systemd/zram-generator.conf
	fi

	dotmpfiles usr/lib/tmpfiles.d/*

	udev_dorules usr/lib/udev/rules.d/*
}

# all tmpfiles are "oneshot at reboot"
pkg_postinst() {
	udev_reload
	tmpfiles_process thp.conf optimize-interruptfreq.conf
}

pkg_postrm() {
	udev_reload
}
