# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 optfeature

DESCRIPTION="Collection of random system bits"
HOMEPAGE="https://github.com/xarblu/sysbits"
EGIT_REPO_URI="https://github.com/xarblu/sysbits.git"

LICENSE="MIT"
SLOT="0"
IUSE="betas binpkg-build-host binpkg-client clang desktop desktop-extra laptop-extra steamdeck-extra server"

REQUIRED_USE="
	desktop-extra? ( desktop )
	laptop-extra? ( desktop )
	steamdeck-extra? ( desktop )
	?? ( desktop server )
"

RDEPEND="
	app-portage/eix
	dev-lang/perl
"

src_compile() { :; }

src_install() {
	emake \
		DESTDIR="${D}" \
		BETAS="$(usex betas)" \
		CLANG="$(usex clang)" \
		DESKTOP="$(usex desktop)" \
		DESKTOP_EXTRA="$(usex desktop-extra)" \
		LAPTOP_EXTRA="$(usex laptop-extra)" \
		STEAMDECK_EXTRA="$(usex steamdeck-extra)" \
		SERVER="$(usex server)" \
		BINPKG_CLIENT_LLVM="$(usex binpkg-client "$(usex clang)" )" \
		BINPKG_BUILD_HOST="$(usex binpkg-build-host)" \
		install
}

pkg_postinst() {
	optfeature "Bcachefs scrub timer/service" sys-fs/bcachefs-tools
	optfeature "Btrfs scrub timer/service" sys-fs/btrfs-progs
}
