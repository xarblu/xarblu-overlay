# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit systemd python-single-r1 desktop wrapper go-module

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
REQUIRED_USE="gui? ( ${PYTHON_REQUIRED_USE} )"

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
		dev-util/blueprint-compiler
		${PYTHON_DEPS}
	)
"

PATCHES=(
	"${FILESDIR}/un-flatpak-0.3.3.patch"
)

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	# set version
	echo "${PV}" > ./cli/cmd/version.txt || die

	# set binary path
	sed -i -e "s|@BINARY_PATH@|/usr/bin/${PN}|" \
		"cli/cmd/${PN}.service" || die

	# desktop file should call our wrapper
	sed -i -e "s/goldwarden_ui_main\.py/${PN}-gui/" \
		gui/com.quexten.Goldwarden.desktop || die
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

	systemd_douserunit "cli/cmd/${PN}.service"

	insinto /usr/share/polkit-1/actions
	doins "cli/resources/com.quexten.goldwarden.policy"

	if use gui; then
		pushd gui || die

		# install python gui files
		local guidir="/usr/lib/${PN}"
		insinto "${guidir}"
		doins -r ./*
		python_optimize "${D}${guidir}"

		# create wrapper
		make_wrapper \
			"${PN}-gui" \
			"${PYTHON} goldwarden_ui_main.py" \
			"${guidir}"

		# metadata files
		domenu com.quexten.Goldwarden.desktop
		doicon -s scalable com.quexten.Goldwarden.svg
		insinto /usr/share/metainfo
		doins com.quexten.Goldwarden.metainfo.xml

		popd || die
	fi
}
