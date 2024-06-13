# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit python-r1 desktop go-module

DESCRIPTION="A feature-packed Bitwarden compatible desktop client"
HOMEPAGE="https://github.com/quexten/goldwarden"
SRC_URI="
	https://github.com/quexten/${PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/xarblu/xarblu-overlay/releases/download/distfiles/${P}-deps.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="fido2 +gui"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	fido2? ( dev-libs/libfido2 )
	gui? (
		$(python_gen_cond_dep '
			dev-python/pygobject:3[${PYTHON_USEDEP}]
			dev-python/tendo[${PYTHON_USEDEP}]
		')
		gui-libs/gtk:4
		gui-libs/libadwaita
		x11-themes/adwaita-icon-theme
		${PYTHON_DEPS}
	)
"
RDEPEND="${DEPEND}"
BDEPEND="
	gui? (
		$(python_gen_any_dep '
			dev-util/blueprint-compiler[${PYTHON_SINGLE_USEDEP}]
		')
		${PYTHON_DEPS}
	)
"

PATCHES=(
	"${FILESDIR}/python-module-rename-0.3.3.patch"
	"${FILESDIR}/un-flatpak-0.3.3.patch"
)

python_check_deps() {
	if use gui; then
		python_has_version "dev-util/blueprint-compiler[${PYTHON_SINGLE_USEDEP}]"
	fi
}

pkg_setup() {
	python_setup
}

src_prepare() {
	echo "${PV}" > ./cli/cmd/version.txt || die
	# give the gui a sane name
	if use gui; then
		pushd gui || die
		sed -i -e "s/goldwarden_ui_main\.py/goldwarden-gui/" \
			com.quexten.Goldwarden.desktop || die
		popd || die
	fi
	default
}

src_compile() {
	local mytags=(
		$(usev !fido2 nofido2)
	)
	local _ifs="${IFS}"
	IFS=","
	mytags="${mytags[*]}"
	IFS="${_ifs}"
	ego build -tags "${mytags}" -o "${PN}" -v .

	if use gui; then
		pushd gui || die
		blueprint-compiler batch-compile \
			src/gui/.templates/ src/gui/ src/gui/*.blp || die
		popd || die
	fi
}

src_install() {
	dobin "${PN}"

	if use gui; then
		pushd gui || die
		mv src "${PN}" || die
		python_foreach_impl python_domodule goldwarden
		python_foreach_impl python_newscript goldwarden_ui_main.py goldwarden-gui
		domenu com.quexten.Goldwarden.desktop
		newicon -s scalable goldwarden.svg com.quexten.Goldwarden.svg
		insinto /usr/share/metainfo
		doins com.quexten.Goldwarden.metainfo.xml
		popd || die
	fi
}
