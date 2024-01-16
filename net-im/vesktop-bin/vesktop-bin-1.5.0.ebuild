# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"
MY_PN="${MY_PN^}"

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop linux-info unpacker xdg wrapper

DESCRIPTION="A standalone Electron app that loads Discord & Vencord"
HOMEPAGE="https://vencord.dev https://github.com/Vencord/Vesktop"
SRC_URI="
	amd64? ( https://github.com/Vencord/${MY_PN}/releases/download/v${PV}/${PN%-bin}_${PV}_amd64.deb )
	arm64? ( https://github.com/Vencord/${MY_PN}/releases/download/v${PV}/${PN%-bin}_${PV}_arm64.deb )
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

IUSE="wayland"

RDEPEND="
	x11-libs/libnotify
	x11-misc/xdg-utils
"
BDEPENDS="
	$(unpacker_src_uri_depends)
"

DESTDIR="/opt/${MY_PN}"

QA_PREBUILT="*"

CONFIG_CHECK="~USER_NS"

src_unpack() {
	mkdir "${S}"
	cd "${S}"
	unpacker ${A}
}

src_prepare() {
	default
	# cleanup languages
	pushd "opt/${MY_PN}/locales/" >/dev/null || die "location change for language cleanup failed"
	chromium_remove_language_paks
	popd >/dev/null || die "location reset for language cleanup failed"

	# point desktop file to wrapper
	sed -i -e "/Exec=/s:${DESTDIR%/}:/usr/bin:" \
		"usr/share/applications/${PN%-bin}.desktop" || die "sed failed"
}

src_configure() {
	default
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	# install desktop stuff
	for size in 16 32 48 64 128 256 512 1024; do
		doicon -s "${size}" "usr/share/icons/hicolor/${size}x${size}/apps/${PN%-bin}.png"
	done
	domenu usr/share/applications/${PN%-bin}.desktop

	# install the rest
	pushd "opt/${MY_PN}" >/dev/null || die "changing dirs failed"
	# executables
	exeinto "${DESTDIR}"
	doexe chrome-sandbox \
		libEGL.so \
		libffmpeg.so \
		libGLESv2.so \
		libvk_swiftshader.so \
		libvulkan.so.1 \
		${PN%-bin}

	# regular files
	insinto "${DESTDIR}"
	doins chrome_100_percent.pak \
		chrome_200_percent.pak \
		icudtl.dat \
		LICENSE.electron.txt \
		LICENSES.chromium.html \
		resources.pak \
		snapshot_blob.bin \
		v8_context_snapshot.bin \
		vk_swiftshader_icd.json

	doins -r locales resources

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fowners root "${DESTDIR}/chrome-sandbox"
	fperms 4711 "${DESTDIR}/chrome-sandbox"

	# Crashpad is included in the package once in a while and when it does, it must be installed.
	# See #903616 and #890595
	[[ -x chrome_crashpad_handler ]] && doexe chrome_crashpad_handler

	popd >/dev/null || die "changing dirs failed"

	# install wrapper, optionally enable ozone via USE wayland
	make_wrapper "${PN%-bin}" "${DESTDIR}/${PN%-bin} $(usev wayland --ozone-platform-hint=auto)"
}
