# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd wrapper

NODE_DEPS="
	ws@8.11.0
	bufferutil@4.0.1
	utf-8-validate@5.0.2
"

DESCRIPTION="Open Discord RPC server for atypical setups"
HOMEPAGE="https://arrpc.openasar.dev/"
SRC_URI="https://github.com/OpenAsar/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="net-libs/nodejs"

node_src_uris() {
	local pkg ver
	for i in ${NODE_DEPS}; do
		pkg="${i%@*}"
		ver="${i#*@}"
		echo "https://registry.npmjs.org/${pkg}/-/${pkg}-${ver}.tgz"
	done
}

SRC_URI+=" $(node_src_uris)"

node_src_unpack() {
	local pkg ver
	cd "${S}" || die
	mkdir node_modules || die
	for i in ${NODE_DEPS}; do
		pkg="${i%@*}"
		ver="${i#*@}"
		mkdir "node_modules/${pkg}"
		tar -C "node_modules/${pkg}" -x -f "${DISTDIR}/${pkg}-${ver}.tgz" || die
		mv "node_modules/${pkg}/package"/* "node_modules/${pkg}" || die
		rmdir "node_modules/${pkg}/package" || die
	done
}

src_unpack() {
	unpack "${P}.tar.gz"
	node_src_unpack
}

src_install() {
	insinto /opt/arrpc
	doins -r ./*
	make_wrapper arrpc "node src" "/opt/arrpc"
	systemd_douserunit "${FILESDIR}/arrpc.service"
}
