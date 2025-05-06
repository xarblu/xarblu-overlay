# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop wrapper

MY_PN="StudIP"
COMMIT="6a6874555f111bcd0aaba22352dc304d49d9f09d"
ELECTRON_V="35.2.2"
BUILDER_APPIMAGE_V="12.0.1"
BUILDER_FPM_V="1.9.3-2.3.1-linux-x86_64"

DESCRIPTION="A toy Stud.IP client"
HOMEPAGE="https://github.com/CommandMC/StudIP"
# howto node_modules tarball:
# - git clean -fdx && git reset --hard main
# (we want pnpm in node_modules because it's not packaged in ::gentoo)
# - NPM_CONFIG_USERCONFIG="" pnpm add pnpm --save-dev --lockfile-only
# - pnpm install
# - XZ_OPTS="-T0 -9" tar -acf studip-0_p20250506-node_modules.tar.xz node_modules
SRC_URI="
	https://github.com/CommandMC/${MY_PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz
	https://github.com/xarblu/xarblu-overlay/releases/download/distfiles/${P}-node_modules.tar.xz
	https://github.com/electron/electron/releases/download/v${ELECTRON_V}/electron-v${ELECTRON_V}-linux-x64.zip
		-> ${P}-electron-v${ELECTRON_V}-linux-x64.zip
	https://github.com/electron-userland/electron-builder-binaries/releases/download/appimage-${BUILDER_APPIMAGE_V}/appimage-${BUILDER_APPIMAGE_V}.7z
		-> ${P}-appimage-${BUILDER_APPIMAGE_V}.7z
	https://github.com/electron-userland/electron-builder-binaries/releases/download/fpm-${BUILDER_FPM_V}/fpm-${BUILDER_FPM_V}.7z
		-> ${P}-fpm-${BUILDER_FPM_V}.7z
"
S="${WORKDIR}/${MY_PN}-${COMMIT}"

# TODO: ADD LICENSE
LICENSE=""
SLOT="0"
KEYWORDS="-* ~amd64"

BDEPEND="
	app-arch/7zip
	app-arch/unzip
	net-libs/nodejs
"

src_unpack() {
	# the electron builder expects these to exist in ~/.cache like this
	# I thought they would ship with node_modules but now we have this ugly mess...
	mkdir -p "${HOME}"/.cache/electron || die
	cp "${DISTDIR}/${P}-electron-v${ELECTRON_V}-linux-x64.zip" \
		"${HOME}/.cache/electron/electron-v${ELECTRON_V}-linux-x64.zip" || die

	mkdir -p "${HOME}"/.cache/electron-builder/{appimage,fpm} || die
	7z x "${DISTDIR}/${P}-appimage-${BUILDER_APPIMAGE_V}.7z" \
		-o"${HOME}/.cache/electron-builder/appimage/appimage-${BUILDER_APPIMAGE_V}" || die
	7z x "${DISTDIR}/${P}-fpm-${BUILDER_FPM_V}.7z" \
		-o"${HOME}/.cache/electron-builder/fpm/fpm-${BUILDER_FPM_V}" || die

	unpack "${P}.tar.gz" "${P}-node_modules.tar.xz"
}

src_prepare() {
	mv "${WORKDIR}/node_modules" . || die
	default
}

src_compile() {
	node_modules/.bin/pnpm build || die

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

	make_wrapper "${PN}" "${dest}/${PN}"
	newicon -s scalable meta/icon_color.svg "${PN}.svg"
	domenu "${FILESDIR}/${PN}.desktop"
}
