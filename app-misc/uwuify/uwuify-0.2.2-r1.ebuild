# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	ansi_term@0.11.0
	atty@0.2.14
	bitflags@1.2.1
	cfg-if@1.0.0
	clap@2.33.3
	hermit-abi@0.1.18
	instant@0.1.9
	libc@0.2.89
	lock_api@0.4.2
	owo-colors@1.3.0
	parking_lot@0.11.1
	parking_lot_core@0.8.3
	proc-macro2@1.0.24
	quote@1.0.9
	redox_syscall@0.2.5
	scopeguard@1.1.0
	smallvec@1.6.1
	strsim@0.8.0
	syn@1.0.64
	textwrap@0.11.0
	thiserror-impl@1.0.24
	thiserror@1.0.24
	unicode-width@0.1.8
	unicode-xid@0.2.1
	vec_map@0.8.2
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
"

inherit cargo

MY_PN="uwu"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="fastest text uwuifier in the west"
HOMEPAGE="https://github.com/Daniel-Liu-c0deb0t/uwu"
SRC_URI="
	https://github.com/Daniel-Liu-c0deb0t/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"
LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
S="${WORKDIR}/${MY_P}"
