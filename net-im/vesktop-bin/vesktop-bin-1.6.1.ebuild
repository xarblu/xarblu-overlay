# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

MY_PN="vesktop"

XDG_PN="dev.vencord.Vesktop"

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop xdg

DESCRIPTION="All-in-one voice and text chat for gamers with Vencord Preinstalled"
HOMEPAGE="https://github.com/Vencord/Vesktop/"
SRC_URI="
	amd64? ( https://github.com/Vencord/Vesktop/releases/download/v${PV}/${MY_PN}-${PV}.tar.gz )
	arm64? ( https://github.com/Vencord/Vesktop/releases/download/v${PV}/${MY_PN}-${PV}-arm64.tar.gz )
	https://raw.githubusercontent.com/Vencord/Vesktop/refs/tags/v${PV}/build/icon.svg -> ${P}.svg
	https://github.com/Vencord/Vesktop/releases/download/v${PV}/${XDG_PN}.metainfo.xml -> ${P}.metainfo.xml
"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="appindicator"
# not as strict as net-im/discord
# because Vesktop is GPL-3 so distributing
# should be fine
RESTRICT="test"

DEPEND="
	app-accessibility/at-spi2-core
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-libs/glibc
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
	appindicator? ( dev-libs/libayatana-appindicator )
"

QA_PREBUILT="/opt/${PN}/*"

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	default
	use arm64 && S="${WORKDIR}/${MY_PN}-${PV}-arm64"
}

src_prepare() {
	default

	pushd locales >/dev/null || die
		chromium_remove_language_paks
	popd >/dev/null || die
}

src_install() {
	local dest="/opt/${PN}"

	insinto "${dest}"
	exeinto "${dest}"

	doins -r locales resources
	doins \
		chrome_100_percent.pak \
		chrome_200_percent.pak \
		icudtl.dat \
		LICENSE.electron.txt \
		LICENSES.chromium.html \
		resources.pak \
		snapshot_blob.bin \
		v8_context_snapshot.bin \
		vk_swiftshader_icd.json

	doexe \
		chrome-sandbox \
		chrome_crashpad_handler \
		libEGL.so \
		libffmpeg.so \
		libGLESv2.so \
		libvk_swiftshader.so \
		libvulkan.so.1 \
		"${MY_PN}"

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fowners root "${dest}/chrome-sandbox"
	fperms 4711 "${dest}/chrome-sandbox"

	dosym "../../${dest}/${MY_PN}" "/usr/bin/${PN}"

	newicon -s scalable "${DISTDIR}/${P}.svg" "${PN}.svg"
	domenu "${FILESDIR}/${PN}.desktop"
	insinto /usr/share/metainfo
	newins "${DISTDIR}/${P}.metainfo.xml" "${XDG_PN}.metainfo.xml"

	# https://bugs.gentoo.org/898912
	if use appindicator; then
		dosym ../../usr/lib64/libayatana-appindicator3.so "/opt/${PN}/libappindicator3.so"
	fi
}
