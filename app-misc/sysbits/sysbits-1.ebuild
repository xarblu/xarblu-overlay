# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature systemd

DESCRIPTION="Collection of random system bits"
HOMEPAGE="https://github.com/xarblu/sysbits"
SRC_URI="https://github.com/xarblu/sysbits/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-portage/eix
	dev-lang/perl
"

src_install() {
	insinto /etc/eixrc
	doins etc/eixrc/*

	insinto /etc/portage
	doins -r etc/portage/{env,package.env,patches}
	doins etc/portage/bashrc
	exeinto /etc/portage/postsync.d
	doexe etc/portage/postsync.d/*

	systemd_dounit usr/lib/systemd/system/*

	insinto /usr/share/sysbits/portage
	doins usr/share/sysbits/portage/bashrc-utils.sh
}

pkg_postinst() {
	optfeature "Bcachefs scrub timer/service" sys-fs/bcachefs-tools
	optfeature "Btrfs scrub timer/service" sys-fs/btrfs-progs
}
