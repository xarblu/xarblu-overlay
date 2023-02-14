# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )

inherit meson pam python-any-r1 systemd

MY_P="${PN}-v${PV}"

DESCRIPTION="PAM module enabling simultaneous fprintd and password authentication"
HOMEPAGE="https://gitlab.com/mishakmak/pam-fprint-grosshack"
SRC_URI="https://gitlab.com/mishakmak/${PN}/-/archive/v${PV}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~riscv ~sparc ~x86"

IUSE="systemd"

RDEPEND="
	sys-auth/fprintd
	sys-libs/pam
	systemd? ( sys-apps/systemd:= )
	!systemd? ( sys-auth/elogind:= )
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	dev-lang/perl
	dev-util/gdbus-codegen
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_P}"

PATCHES=( ${FILESDIR}/remove-test-deps.patch )

src_configure() {
	local emesonargs=(
		-Dpam=true
		-Dpam_modules_dir="$(getpam_mod_dir)"
	)
	meson_src_configure
}
