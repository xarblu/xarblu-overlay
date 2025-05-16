# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 optfeature systemd

DESCRIPTION="Collection of random system bits"
HOMEPAGE="https://github.com/xarblu/sysbits"
EGIT_REPO_URI="https://github.com/xarblu/sysbits.git"

LICENSE="MIT"
SLOT="0"
IUSE="betas clang desktop desktop-extra laptop-extra"

REQUIRED_USE="
	desktop-extra? ( desktop )
	laptop-extra? ( desktop )
"

RDEPEND="
	app-portage/eix
	dev-lang/perl
"

src_install() {
	# Profile / Environment
	insinto /etc/profile.d
	doins etc/profile.d/*

	# Portage and Friends
	pushd etc/portage >/dev/null || die
		insinto /etc/portage
		doins -r env

		pushd package.accept_keywords >/dev/null || die
			insinto /etc/portage/package.accept_keywords
			doins 00-sysbits
			use betas && doins 10-openjdk
			use betas && doins 20-llvm
			use betas && doins 50-kde-plasma-6.3.90
			use betas && doins 60-kernel-rcs
		popd >/dev/null || die

		pushd package.env >/dev/null || die
			insinto /etc/portage/package.env
			use clang && doins 10-llvm-fixes
			doins 15-general-fixes
		popd >/dev/null || die

		pushd package.mask >/dev/null || die
			insinto /etc/portage/package.mask
			doins 00-versions
			doins 01-repos
		popd >/dev/null || die

		pushd package.unmask >/dev/null || die
			insinto /etc/portage/package.unmask
			doins 01-repos
			use betas && doins 02-qt6
			use betas && doins 05-mesa
			use betas && doins 06-kde-plasma-6.4
		popd >/dev/null || die

		pushd package.use >/dev/null || die
			insinto /etc/portage/package.use
			use desktop && doins 00-global-common
			use desktop-extra && doins 01-global-desktop
			doins 10-alternatives
			use desktop && doins 20-toolchain
			use desktop && doins 30-32bit
			use desktop && doins 40-python-targets
			use desktop && doins 50-llvm-slots
			use desktop && doins 60-no-X
			use desktop && doins 90-other-common
			use desktop-extra && doins 91-other-desktop
		popd >/dev/null || die

		insinto /etc/portage
		doins -r patches

		exeinto /etc/portage/postsync.d
		doexe postsync.d/*

		pushd profile/package.use.mask >/dev/null || die
			insinto /etc/portage/profile/package.use.mask
			use desktop && doins features
			use betas && doins llvm-slots
		popd >/dev/null || die

		insinto /etc/portage
		doins -r repos.conf
		doins -r sets
		doins bashrc
		use desktop && newins 'make.conf#desktop' make.conf

	popd >/dev/null || die

	insinto /usr/share/sysbits/portage
	doins usr/share/sysbits/portage/bashrc-utils.sh

	insinto /etc/eixrc
	doins etc/eixrc/*

	# Systemd
	systemd_dounit usr/lib/systemd/system/*
}

pkg_postinst() {
	optfeature "Bcachefs scrub timer/service" sys-fs/bcachefs-tools
	optfeature "Btrfs scrub timer/service" sys-fs/btrfs-progs
}
