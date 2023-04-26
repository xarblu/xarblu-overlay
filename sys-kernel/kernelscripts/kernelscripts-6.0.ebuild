# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Basic scripts to manage kernels on Gentoo Linux"
HOMEPAGE="https://github.com/xarblu/kernelscripts"
SRC_URI="https://github.com/xarblu/kernelscripts/archive/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	|| ( sys-kernel/installkernel-gentoo sys-kernel/installkernel-systemd-boot )
"

src_install() {
	exeinto /usr/bin
	doexe kernelbuilder
}
