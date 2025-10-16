# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck shell=bash
# shellcheck disable=SC2034

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop wrapper unpacker

MY_PN="StudIP"
COMMIT="e0083017cffe1049794fcb0595d127bfc8e50051"
ELECTRON_V="38.3.0"
BUILDER_APPIMAGE_V="12.0.1"
BUILDER_FPM_V="1.9.3-2.3.1-linux-x86_64"
SNAP_TEMPLATE_V="4.0-2"

DESCRIPTION="A toy Stud.IP client"
HOMEPAGE="https://github.com/CommandMC/StudIP"
# howto node_modules tarball:
# - git clean -fdx
# - apply ${FILESDIR}/electron-bundle.patch
# - pnpm install
# - XZ_OPTS="-T0 -9" tar -acf studip-0_pCHANGEME-node_modules.tar.xz node_modules
SRC_URI="
	https://github.com/CommandMC/${MY_PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz
	https://github.com/xarblu/xarblu-overlay/releases/download/distfiles/${P}-node_modules.tar.xz
	https://github.com/electron/electron/releases/download/v${ELECTRON_V}/electron-v${ELECTRON_V}-linux-x64.zip
		-> ${P}-electron-v${ELECTRON_V}-linux-x64.zip
	https://github.com/electron-userland/electron-builder-binaries/releases/download/appimage-${BUILDER_APPIMAGE_V}/appimage-${BUILDER_APPIMAGE_V}.7z
		-> ${P}-appimage-${BUILDER_APPIMAGE_V}.7z
	https://github.com/electron-userland/electron-builder-binaries/releases/download/fpm-${BUILDER_FPM_V}/fpm-${BUILDER_FPM_V}.7z
		-> ${P}-fpm-${BUILDER_FPM_V}.7z
	https://github.com/electron-userland/electron-builder-binaries/releases/download/snap-template-${SNAP_TEMPLATE_V}/snap-template-electron-${SNAP_TEMPLATE_V}-amd64.tar.7z
		-> ${P}-snap-template-electron-${BUILDER_FPM_V}-amd64.7z
"
S="${WORKDIR}/${MY_PN}-${COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"

BDEPEND="
	app-arch/unzip
	net-libs/nodejs
	$(unpacker_src_uri_depends)
"

PATCHES=( "${FILESDIR}/electron-bundle-${PV}.patch" )

# bundled electron binaries
QA_PREBUILT="/opt/studip/*"

src_unpack() {
	# the electron builder expects these to exist in ~/.cache like this
	# I thought they would ship with node_modules but now we have this ugly mess...
	mkdir -p "${HOME}"/.cache/electron || die
	cp "${DISTDIR}/${P}-electron-v${ELECTRON_V}-linux-x64.zip" \
		"${HOME}/.cache/electron/electron-v${ELECTRON_V}-linux-x64.zip" || die

	local -A archives=(
		["${P}-appimage-${BUILDER_APPIMAGE_V}.7z"]="${HOME}/.cache/electron-builder/appimage/appimage-${BUILDER_APPIMAGE_V}"
		["${P}-fpm-${BUILDER_FPM_V}.7z"]="${HOME}/.cache/electron-builder/fpm/fpm-${BUILDER_FPM_V}"
		["${P}-snap-template-electron-${BUILDER_FPM_V}-amd64.7z"]="${HOME}/.cache/electron-builder/snap/snap-template-electron-${SNAP_TEMPLATE_V}-amd64"
	)

	local file dest
	for file in "${!archives[@]}"; do
		dest="${archives["${file}"]}"
		mkdir -p "${dest}" || die
		pushd "${dest}" >/dev/null || die
		unpacker "${file}"
		popd >/dev/null || die
	done

	# now the regular unpack
	unpack "${P}.tar.gz" "${P}-node_modules.tar.xz"
}

src_prepare() {
	mv "${WORKDIR}/node_modules" . || die
	default
}

src_compile() {
	export npm_config_offline=true
	export npm_config_loglevel=verbose
	export npm_config_update_notifier=false
	export DEBUG=electron-builder
	export PATH="node_modules/.bin:${PATH}"

	einfo "electron-vite build"
	electron-vite build || die
	einfo "electron-builder build"
	electron-builder build || die

	pushd dist/linux-unpacked/locales >/dev/null || die
		chromium_remove_language_paks
	popd >/dev/null || die
}

src_install() {
	local dest="/opt/studip"
	insinto "${dest}"
	exeinto "${dest}"

	pushd dist/linux-unpacked >/dev/null || die
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
			"${PN}"

		# Chrome-sandbox requires the setuid bit to be specifically set.
		# see https://github.com/electron/electron/issues/17972
		fowners root "${dest}/chrome-sandbox"
		fperms 4711 "${dest}/chrome-sandbox"
	popd >/dev/null || die

	make_wrapper "${PN}" "${dest}/${PN} --ozone-platform-hint=auto"
	newicon -s scalable assets/icon_color.svg "${PN}.svg"
	domenu "${FILESDIR}/${PN}.desktop"
}
