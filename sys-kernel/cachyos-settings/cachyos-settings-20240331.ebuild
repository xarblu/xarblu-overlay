# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit udev tmpfiles systemd

COMMIT="1e65d4696d0836b4b727ce61f3a29376a11e99a7"
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
	insinto /etc/modprobe.d
	doins etc/modprobe.d/*

	insinto /etc/security/limits.d
	doins etc/security/limits.d/*

	insinto /etc/sysctl.d
	doins etc/sysctl.d/*

	insinto /etc/systemd/journald.conf.d
	doins etc/systemd/journald.conf.d/*

	insinto /etc/systemd/system.conf.d
	doins etc/systemd/system.conf.d/*

	# this explicitly doesn't install the
	# .service files because we don't install
	# the scripts
	local dir file unit
	for dir in etc/systemd/system/*.d; do
		unit="${dir##*/}"
		unit="${unit%.d}"
		for file in "${dir}"/*; do
			systemd_install_dropin "${unit}" "${file}"
		done
	done

	insinto /etc/systemd/user.conf.d
	doins etc/systemd/user.conf.d/*

	if use zram; then
		insinto /etc/systemd
		doins etc/systemd/zram-generator.conf
	fi

	dotmpfiles etc/tmpfiles.d/*

	udev_dorules etc/udev/rules.d/*
}

# all tmpfiles are "oneshot at reboot"
pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
